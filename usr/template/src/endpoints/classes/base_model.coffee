Bookshelf = require('./database')
instanceProps = {}
classProps = transaction: Bookshelf.transaction.bind(Bookshelf)
module.exports = Bookshelf.Model.extend(instanceProps, classProps)
