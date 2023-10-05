/**
 * @description Trigger for handling Object Share Instruction platform events
 *
 * @see CMN_TRA_ObjectShareInstruction
 *
 * @author vishakha.saini@accenture.com
 *
 * @date June 2022
 */
trigger CMN_TRG_ObjectShareInstruction on CMN_ObjectShareInstruction__e (after insert)
{
	new CMN_FACTORY_TriggerAction().run();
}