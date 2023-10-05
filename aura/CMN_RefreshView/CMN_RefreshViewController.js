/**
 * @description Reusable Aura Component that listens for aura://refreshView custom event and refreshes the view
 *
 * @author Accenture
 *
 * @date June 2021
 */

({
    onInit: function (component, event, helper) {
        document.addEventListener("aura://refreshView", () => {
            $A.get('e.force:refreshView').fire();
        });
    }
});