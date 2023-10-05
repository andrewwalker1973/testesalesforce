/**
 * @description Trigger for handling Shared Object Change Instruction platform events
 *
 * @see CMN_TRA_ObjectShareChangeInstruct
 *
 * @author vishakha.saini@accenture.com
 *
 * @date June 2022
 */
trigger CMN_TRG_ObjectShareChangeInstruction on CMN_ObjectShareChangeInstruction__e (after insert)
{
	new CMN_FACTORY_TriggerAction().run();
}