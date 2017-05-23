graze = require 'graze'

db = require '../models'
sql = db.sequelize

PREFIX = 'http://law.justia.com/codes/mississippi/2015'

justia_title_url = (number) ->
  "#{PREFIX}/title-#{number}/index.html"

code_list_parser = graze.template
  'ul > li > a':
    results: [
      (el) ->
        if el.attr().href.startsWith '/code'
          href = el.attr().href
          ptype = (path.basename path.dirname href).split('-')[0]
          console.log ptype, href
          number: (path.basename path.dirname href).split('-')[1]
          title: el.text().split(' - ')[1]
          ptype: ptype
          href: href
        else
          false
    ]
    
get_list_results = (data) ->
  f for f in data.results when f

attatch_title_to_chapters = (title_id, chapters) ->
  nchapters = []
  for ch in chapters
    ch.ms_title_id = title_id
    nchapters.push ch
  nchapters

insert_chapters = (title_num) ->
  url = justia_title_url title_num
  p = code_list_parser.scrape url
  p.then (data) ->
    r = get_list_results data
    insert_scraped_chapters title_num, r


insert_scraped_chapters = (title_num, chapters) ->
  sql.models.ms_titles.findOne
    where:
      number: title_num
  .then (title) ->
    title_id = title.id
    console.log 'title_id', title_id, title.title
    sql.models.ms_chapters.findAll
      where:
        ms_title_id: title_id
    .then (chptr_rows) ->
      #console.log "chapter_rows", chptr_rows
      if not chptr_rows.length
        console.log "hello?"
        nchapters = attatch_title_to_chapters title_id, chapters
        sql.models.ms_chapters.bulkCreate nchapters, (result) ->
          console.log "chapters inserted?", result
      else
        console.log "We have chapter_rows ALREADY", chptr_rows.length
    .catch (err) ->
      console.log "ERROR", err
  .catch (err) ->
    console.log "TITLE ERROR", err


titles_url = PREFIX
titles_fname = 'assets/ms_titles.html'

    
