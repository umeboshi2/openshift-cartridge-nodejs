# parse house members
member_info = ['bgc', 'link', 'name']

make_info_tag = (number, tag) ->
  "m#{number}_#{tag}"

parse_hr_memb_section = (section) ->
  msection = []
  seclength = Object.keys(section).length
  if seclength != 15
    throw Error "Bad times"
  for number in [1,2,3,4,5]
    member = {}
    for tag in member_info
      infotag = make_info_tag number, tag
      #console.log "number", infotag
      value = section[infotag]
      #console.log "value", infotag, value
      member[tag] = section[infotag]
      if tag == 'link'
        parts = value.split('/')
        last = parts[parts.length - 1]
        member.id = last.split('.')[0]
    msection.push member
  msection
  
parse_hr_membs = (json) ->
  members = {}
  memberlist = json.legislature.member
  parsed = []
  for section in memberlist
    msection = parse_hr_memb_section section
    parsed = parsed.concat msection
  parsed

