import { LightningElement, wire, track } from 'lwc';
import getClientAccountInfo from "@salesforce/apex/AW_CTR_ClientCommunity.getClientAccountInfo";
import chartJS from "@salesforce/resourceUrl/ChartJS";
import { loadScript } from "lightning/platformResourceLoader";

export default class AwLwcFinancialHoldings extends LightningElement {

  @track accountInfo;
  @track accountInfoError;
  @track chartData;
  wiredAccountInfo;

  @wire(getClientAccountInfo) account(result) {
    this.wiredAccountInfo = result;
    if (result.data) {
      this.accountInfo = result.data;
      this.accountInfoError = undefined;
    } else if (result.error) {
      this.accountInfoError = result.error;
      this.accountInfo = undefined;
    }
  }

  renderedCallback() {
    Promise.all([loadScript(this, chartJS + "/Chart.min.js")])
      .then(() => {
        this.chartJSLoaded = true;
        console.log("ChartJS Loaded....");
        this.initializeCharts();
      })
      .catch(error => {
        console.log("Error Loading ChartJS: " + error);
      });
  }

  //TODO: Merge with doughnut component
  initializeCharts() {

    Chart.pluginService.register({
      beforeDraw: function (chart) {
        if (chart.config.options.elements.center) {
          //Get ctx from string
          let ctx = chart.chart.ctx;

          //Get options from the center object in options
          let centerConfig = chart.config.options.elements.center;
          let fontStyle = centerConfig.fontStyle || 'Noto Sans';
          let txt = centerConfig.text;
          let color = centerConfig.color || '#000';
          let sidePadding = centerConfig.sidePadding || 20;
          let sidePaddingCalculated = (sidePadding / 100) * (chart.innerRadius * 2)
          //Start with a base font of 30px
          ctx.font = "30px " + fontStyle;

          //Get the width of the string and also the width of the element minus 10 to give it 5px side padding
          let stringWidth = ctx.measureText(txt).width;
          let elementWidth = (chart.innerRadius * 2) - sidePaddingCalculated;

          // Find out how much the font can grow in width.
          let widthRatio = elementWidth / stringWidth;
          let newFontSize = Math.floor(25 * widthRatio);
          let elementHeight = (chart.innerRadius * 2);

          // Pick a new font size so it will not be larger than the height of label.
          let fontSizeToUse = Math.min(newFontSize, elementHeight);

          //Set font settings to draw it correctly.
          ctx.textAlign = 'center';
          ctx.textBaseline = 'middle';
          let centerX = ((chart.chartArea.left + chart.chartArea.right) / 2);
          let centerY = ((chart.chartArea.top + chart.chartArea.bottom) / 2);
          ctx.font = fontSizeToUse + "px " + fontStyle;
          ctx.fillStyle = color;

          //Draw text in center
          ctx.fillText(txt, centerX, centerY);
        }
      }
    });

    let config = {
      type: 'doughnut',
      data: {
        labels: [
          "Total Investments",
          "Total Retirement",
          "Other Assets"
        ],
        datasets: [{
          data: [this.accountInfo.AW_TotalRetirement__c, this.accountInfo.AW_TotalInvestments__c, this.accountInfo.AW_TotalAssets__c],
          backgroundColor: ["rgb(85, 129, 239)", "rgba(235, 235, 235)", "rgba(33, 73, 191)"],
          borderWidth: 0,
          hoverBackgroundColor: ["rgb(85, 129, 239)", "rgba(235, 235, 235)", "rgba(33, 73, 191)"]
        }]
      },
      options: {
        elements: {
          center: {
            text: "R " + currencyAbbr(this.accountInfo.AW_CLIENT_TotalAssets__c, 1),
            color: '#FFFFFF', // Default is #000000
            fontStyle: 'Noto Sans', // Default is Arial
            sidePadding: 20 // Defualt is 20 (as a percentage)
          }
        },
        responsive: false,
        legend: {
          display: false
        },
        cutoutPercentage: 90,
        tooltips: {
          callbacks: {
            // this callback is used to create the tooltip label
            label: function (tooltipItem, data) {
              // get the data label and data value to display
              // convert the data value to local string so it uses a comma seperated number
              var dataLabel = data.labels[tooltipItem.index];
              var value = ': R ' + data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toLocaleString();

              if (Chart.helpers.isArray(dataLabel)) {
                // show value on first line of multiline label
                // need to clone because we are changing the value
                dataLabel = dataLabel.slice();
                dataLabel[0] += value;
              } else {
                dataLabel += value;
              }

              // return the text to display on the tooltip
              return dataLabel;
            }
          }
        }
      }
    };

    let ctx = this.template.querySelector("canvas").getContext("2d");
    let myChart = new Chart(ctx, config);

  }

}

//TODO: Move to shared function component
function currencyAbbr(number, decPlaces) {
  // 2 decimal places => 100, 3 => 1000, etc
  decPlaces = Math.pow(10, decPlaces);

  // Enumerate number abbreviations
  let abbrev = ["k", "m", "b", "t"];

  // Go through the array backwards, so we do the largest first
  for (let i = abbrev.length - 1; i >= 0; i--) {

    // Convert array index to "1000", "1000000", etc
    let size = Math.pow(10, (i + 1) * 3);

    // If the number is bigger or equal do the abbreviation
    if (size <= number) {
      // Here, we multiply by decPlaces, round, and then divide by decPlaces.
      // This gives us nice rounding to a particular decimal place.
      number = Math.round(number * decPlaces / size) / decPlaces;

      // Handle special case where we round up to the next abbreviation
      if ((number === 1000) && (i < abbrev.length - 1)) {
        number = 1;
        i++;
      }

      // Add the letter for the abbreviation
      number += abbrev[i];

      break;
    }
  }

  return number;
}