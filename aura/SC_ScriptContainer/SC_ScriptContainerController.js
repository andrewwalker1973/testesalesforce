/**
 * @description Container component for displaying scripts
 *
 * @author vikrant.goswami@accenture.com
 *
 * @see @story 297812
 *
 * @date July 2022
 */

({
	onInit: function(component)
	{
		component.set('v.showKnowledgeScript', false);
	},

	onRecordIdChange: function(component)
	{
		let recordId = component.get('v.recordId');
		let workspaceAPI = component.find('workspace');
		component.set('v.showKnowledgeScript', false);

		//noinspection JSUnresolvedFunction
		workspaceAPI.getFocusedTabInfo().then(function(focusedTabInfoResponse)
		{
			if(focusedTabInfoResponse.tabId)
			{
				//noinspection JSUnresolvedFunction
				workspaceAPI.isSubtab({tabId: focusedTabInfoResponse.tabId}).then(function(isSubTab)
				{
					if(isSubTab)
					{
						//noinspection JSUnresolvedFunction,JSUnresolvedVariable
						workspaceAPI.getTabInfo({tabId: focusedTabInfoResponse.parentTabId}).then(function(parentTabInfo)
						{
							component.set('v.caseId', parentTabInfo.recordId);
							component.set('v.showKnowledgeScript', true);
						}).catch(function(getTabInfoError)
						{
							// eslint-disable-next-line no-console
							console.error('Could not get parent tab info', JSON.stringify(getTabInfoError));
						});
					}
					else
					{
						component.set('v.caseId', recordId);
						component.set('v.showKnowledgeScript', true);
					}
				});
			}
			else if(recordId)
			{
				component.set('v.caseId', recordId);
				component.set('v.showKnowledgeScript', true);
			}
			else
			{
				component.set('v.caseId', null);
				component.set('v.showKnowledgeScript', true);
			}
		})
		.catch(function(focusedTabError)
		{
			// eslint-disable-next-line no-console
			console.error('Focused Tab info could not be retrieved: ', JSON.stringify(focusedTabError));
		});

	}
});