config = require 'tbirds/app-config'
config.userMenuApp = require './user-menu-view'
config.hasUser = true

config.brand.label = '#'
config.brand.url = '#'
misc_menu =
  label: 'Misc Applets'
  menu: [
    {
      label: 'Bumblr'
      url: '#bumblr'
    }
    {
      label: 'Hubby'
      url: '#hubby'
    }
  ]

config.navbarEntries = [
  {
    label: 'Admin'
    url: '/admin'
  }
  {
    label: 'Fantasy'
    url: '/#fantasy'
  }
  {
    label: 'Annex'
    url: '#annex'
  }
  {
    label: 'Dbdocs'
    url: '#dbdocs'
  }
  misc_menu
  {
    label: 'Another'
    menu: [
      {
        label: 'Crud'
        url: '#crud'
      }
      {
        label: 'MS Code'
        url: '#mscode'
      }
      {
        label: 'MSLeg'
        url: '#msleg'
      }
    ]
  }
  ]


module.exports = config
