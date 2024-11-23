import ApexCharts from 'apexcharts'

const Charts = {
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
};

export default Charts;