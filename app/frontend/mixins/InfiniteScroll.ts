import Vue from 'vue'
import Component from 'vue-class-component'
import {get} from "lodash-es";

@Component
export default class InfiniteScroll extends Vue {
  infiniteScrollTimeout = 200
  _infiniteScrollTimer?: number = null
  inhibitScroll: () => boolean  = () => false

  scrolled() {
    this.handleScroll(true)
  }

  private handleScroll(delay: boolean) {
    if (!delay) {
      const topOfLastPage = this.$el.scrollHeight - this.$el.clientHeight
      const headerSize = get(this.$refs, 'header.clientHeight', 0)
      const footerSize = get(this.$refs, 'footer.clientHeight', 0)
      const isAtTop = this.$el.scrollTop <= headerSize
      const isAtBottom = this.$el.scrollTop >= topOfLastPage - footerSize

      if (this.inhibitScroll()) return
      if (isAtTop) this.$emit('top')
      if (isAtBottom) this.$emit('bottom')
    } else {
      if (this._infiniteScrollTimer) window.clearTimeout(this._infiniteScrollTimer)
      this._infiniteScrollTimer = window.setTimeout(this.handleScroll, this.infiniteScrollTimeout)
    }
  }

  mounted() {
    this.$el.addEventListener('scroll', this.scrolled)
  }
}
