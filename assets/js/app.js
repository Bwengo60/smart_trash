import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import ApexCharts from "apexcharts"
// import {Charts} from "./hooks/charts"

// Ensure Hooks is defined correctly
const Hooks = {
  Charts : {
    mounted() {
      console.log("Charts hook mounted");
      this.charts = {};
  
      this.handleEvent("init-charts", ({ charts }) => {
        console.log("Init charts event received:", charts);
        charts.forEach(chartData => {
          this.initChart(chartData);
        });
      });
  
      this.handleEvent("update-charts", ({ charts }) => {
        console.log("Update charts event received:", charts);
        charts.forEach(chartData => {
          this.updateChart(chartData);
        });
      });
    },
    initChart(chartData) {
      console.log("Initializing chart:", chartData);
      
      // Ensure series is a number
      const seriesValue = Array.isArray(chartData.series) 
        ? (typeof chartData.series[0] === 'number' 
            ? chartData.series[0] 
            : 0) 
        : (typeof chartData.series === 'number' 
            ? chartData.series 
            : 0);
  
      const options = {
        series: [seriesValue],
        chart: {
          height: 250,
          type: 'radialBar',
        },
        plotOptions: {
          radialBar: {
            hollow: {
              size: '70%',
            },
            dataLabels: {
              name: {
                show: false,
              },
              value: {
                fontSize: '30px',
                show: true,
                formatter: function (val) {
                  return Math.round(val) + '%';
                }
              }
            },
            track: {
              background: '#f2f2f2',
            },
          }
        },
        colors: [chartData.color || "#10B981"],
        labels: chartData.labels || ["Trash Level"],
      };
      
      const chartElement = document.querySelector(`#chart-${chartData.id}`);
      if (chartElement) {
        // Destroy existing chart if it exists
        if (this.charts[chartData.id]) {
          this.charts[chartData.id].destroy();
        }
  
        const chart = new ApexCharts(chartElement, options);
        chart.render();
        this.charts[chartData.id] = chart;
        
        console.log(`Chart for ID ${chartData.id} initialized with value: ${seriesValue}`);
      } else {
        console.error(`Chart element #chart-${chartData.id} not found`);
      }
    },
    updateChart(chartData) {
      console.log("Updating chart:", chartData);
      
      // Ensure series is a number
      const seriesValue = Array.isArray(chartData.series) 
        ? (typeof chartData.series[0] === 'number' 
            ? chartData.series[0] 
            : 0) 
        : (typeof chartData.series === 'number' 
            ? chartData.series 
            : 0);
  
      const chart = this.charts[chartData.id];
      if (chart) {
        chart.updateOptions({
          series: [seriesValue],
          colors: [chartData.color || "#10B981"],
          labels: chartData.labels || ["Trash Level"]
        });
        console.log(`Chart for ID ${chartData.id} updated with value: ${seriesValue}`);
      } else {
        console.warn(`No chart found for ID ${chartData.id}. Initializing instead.`);
        this.initChart(chartData);
      }
    },
    destroyed() {
      console.log("Charts hook destroyed");
      Object.values(this.charts).forEach(chart => {
        chart.destroy();
      });
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks  // Make sure this matches the exact property name
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket