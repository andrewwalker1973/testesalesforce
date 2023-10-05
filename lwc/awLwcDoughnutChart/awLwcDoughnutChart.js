import chartJS from '@salesforce/resourceUrl/ChartJS';
import {loadScript} from 'lightning/platformResourceLoader';
import {api, LightningElement} from 'lwc';

export default class AwLwcDoughnutChart extends LightningElement
{

	@api percentageComplete;
	@api chartData;

	renderedCallback()
	{
		Promise.all([loadScript(this, chartJS + '/Chart.min.js')])
		.then(() =>
		{
			//this.chartJSLoaded = true;
			this.initializeCharts();
		})
		.catch(error =>
		{
			
		});
	}

	initializeCharts()
	{
		let canvas = this.template.querySelector('canvas');
		//noinspection JSUnresolvedFunction
		const myChart = new Chart(canvas.getContext('2d'), {
			type: 'doughnut', data: {
				datasets: [
					{
						data: [
							this.percentageComplete,
							100 - this.percentageComplete
						],
						backgroundColor: [
							'#44c173',
							'#ebebeb'
						],
						borderWidth: 0
					}
				]
			}, options: {
				responsive: false, tooltips: {
					enabled: false
				}, legend: {
					display: false
				}
			}
		});
	}

	updateChart()
	{
		let canvas = this.template.querySelector('canvas');
		canvas.update();
	}

}