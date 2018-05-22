import Vue from 'vue';
import $ from 'jquery';
import axios from 'axios';

const Page = () => import('../views/' + $('body').attr('page') + '.vue');

axios.defaults.headers.common['X-CSRF-Token'] = $('meta[name="csrf-token"]').attr('content');
window.$ = $;
window.Vue = Vue;
window.Axios = axios;
Vue.prototype.$axios = axios;
//初始化Vue
window.vm = new Vue({
    el: document.body.appendChild(document.createElement('el')),
    render: x => x(Page)
});