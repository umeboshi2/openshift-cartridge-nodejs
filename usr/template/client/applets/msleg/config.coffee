billstatus = 'http://billstatus.ls.state.ms.us'
module.exports =
  production:
    allmsrs: "#{billstatus}/2017/pdf/all_measures/allmsrs.xml"
    hr_membs: "#{billstatus}/members/hr_membs.xml"
  development:
    allmsrs: '/assets/allmsrs.xml'
    hr_membs: '/assets/hr_membs.xml'
