const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
    new webpack.ProvidePlugin({
        $: 'jquery/src/jquery',
        jQuery: 'jquery/src/jquery',
        Swiper: 'swiper/js/swiper',
        BigNumber: 'bignumber.js',
        Vue: 'vue/dist/vue',
        VConsole: 'vconsole',
    })
)

module.exports = environment
