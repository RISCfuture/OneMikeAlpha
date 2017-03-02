const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
environment.loaders.prepend('erb', erb)

environment.loaders.delete('nodeModules') // until https://github.com/mapbox/mapbox-gl-js/issues/3422 is fixed

module.exports = environment
