// Tree-shakeable ECharts — only import chart types and components you use.
// Add more as needed: https://echarts.apache.org/handbook/en/basics/import#shrinking-bundle-size
import * as echarts from "echarts/core"
import {CanvasRenderer} from "echarts/renderers"
import {LineChart, BarChart, PieChart} from "echarts/charts"
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  DataZoomComponent,
  ToolboxComponent,
} from "echarts/components"

echarts.use([
  CanvasRenderer,
  LineChart, BarChart, PieChart,
  TitleComponent, TooltipComponent, LegendComponent,
  GridComponent, DataZoomComponent, ToolboxComponent,
])

const ECharts = {
  mounted() {
    this.chart = echarts.init(this.el, this._theme(), {renderer: "canvas"})

    this.handleEvent("echarts:update", ({option}) => {
      this.chart.setOption(option, {notMerge: this.el.dataset.noMerge === "true"})
    })

    this.handleEvent("echarts:resize", () => this.chart.resize())

    this._resizeObserver = new ResizeObserver(() => this.chart.resize())
    this._resizeObserver.observe(this.el)

    // If server pushed initial option via data attribute
    const initial = this.el.dataset.option
    if (initial) {
      this.chart.setOption(JSON.parse(initial))
    }
  },

  updated() {
    this.chart.resize()
  },

  destroyed() {
    this._resizeObserver.disconnect()
    this.chart.dispose()
  },

  _theme() {
    return document.documentElement.classList.contains("dark") ? "dark" : null
  }
}

export default ECharts
