exports.up = (knex, Promise) ->
  Promise.all [
    knex.schema.createTable('ms_titles', (table) ->
      table.integer('id').primary()
      table.text('number').unique()
      table.text 'title'
      table.text 'description'
      table.timestamps()
      return
    )
    knex.schema.createTable('ms_chapters', (table) ->
      table.integer('id').primary()
      table.text('number')
      table.text 'title'
      table.text 'description'
      table.integer('ms_title_id')
      table.foreign('ms_title_id').references('ms_titles.id')
      table.timestamps()
      return
    )
    knex.schema.createTable('ms_sections', (table) ->
      table.integer('id').primary()
      table.text('number')
      table.text 'title'
      table.text 'description'
      table.integer('ms_chapter_id')
      table.foreign('ms_chapter_id').references('ms_chapters.id')
      table.timestamps()
      return
    )
  ]
  


exports.down = (knex, Promise) ->
  Promise.all [
    knex.schema.dropTable 'ms_titles'
    knex.schema.dropTable 'ms_chapters'
    knex.schema.dropTable 'ms_sections'
  ]

