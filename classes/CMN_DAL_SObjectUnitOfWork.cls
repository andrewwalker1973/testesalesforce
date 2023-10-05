/**
 * @description Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 * <p/>
 *  Provides an implementation of the Enterprise Application Architecture Unit Of Work, as defined by Martin Fowler
 *   https://martinfowler.com/eaaCatalog/unitOfWork.html
 * <p/>
 * "When you're pulling data in and out of a database, it's important to keep track of what you've changed; otherwise,
 *  that data won't be written back into the database. Similarly you have to insert new objects you create and
 *  remove any objects you delete."
 * <p/>
 * "You can change the database with each change to your object model, but this can lead to lots of very small database calls,
 *  which ends up being very slow. Furthermore it requires you to have a transaction open for the whole interaction, which is
 *  impractical if you have a business transaction that spans multiple requests. The situation is even worse if you need to
 *  keep track of the objects you've read so you can avoid inconsistent reads."
 * <p/>
 * "A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you're done,
 *  it figures out everything that needs to be done to alter the database as a result of your work."
 * <p/>
 * In an Apex context this pattern provides the following specific benefits
 * - Bulks DML operations
 * - Manages a business transaction around the work and ensures a rollback occurs (even when exceptions are later handled by the caller)
 * - Honours dependency rules between records and updates dependent relationships automatically during the commit
 * <p/>
 * Please refer to the testMethod's in this class for example usage
 * <p/>
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 * <p/>
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *   may be used to endorse or promote products derived from this software without
 *   specific prior written permission.
 * <p/>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @see CMN_DAL_SObjectUnitOfWork_TEST
 *
 * @author FinancialForce.com, jason.van.beukering@accenture.com
 *
 * @date April 2022, July 2023
 */
@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity')
public virtual inherited sharing class CMN_DAL_SObjectUnitOfWork implements CMN_INT_SObjectUnitOfWork
{
	@TestVisible
	private final List<String> registeredObjectNames = new List<String>();
	private final Map<String, List<SObject>> newListByTypeMap = new Map<String, List<SObject>>();
	private final Map<String, Map<Id, SObject>> deleteByTypeMap = new Map<String, Map<Id, SObject>>();
	private final Map<String, Map<Id, SObject>> dirtyByTypeMap = new Map<String, Map<Id, SObject>>();
	private final Map<String, Relationships> relationshipsMap = new Map<String, Relationships>();
	private static final String ERROR_NEW_CANNOT_BE_DIRTY = 'New records cannot be registered as dirty';
	private static final String ERROR_NEW_RECORDS_CANNOT_BE_REGISTERED_FOR_DELETION = 'New records cannot be registered for deletion';
	private static final String ERROR_OBJECT_TYPE_NOT_SUPPORTED = 'SObject type {0} is not supported by this unit of work';
	private static final String ERROR_ONLY_NEW_RECORDS_CAN_BE_REGISTERED_AS_NEW = 'Only new records can be registered as new';

	/**
	 * @description Constructor of this class
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	public CMN_DAL_SObjectUnitOfWork()
	{
	}

	/**
	 * @description Constructs a new UnitOfWork to support work against the given object list
	 *
	 * @param sObjectTypes A list of objects given in dependency order (least dependent first)
	 */
	public CMN_DAL_SObjectUnitOfWork(List<SObjectType> sObjectTypes)
	{
		this();
		addSObjectTypes(sObjectTypes);
	}

	/**
	 * @description Registers object types for the unit of work
	 *
	 * @param objectTypes A lists of types
	 */
	public void addSObjectTypes(List<SObjectType> objectTypes)
	{
		for(SObjectType objectType : objectTypes)
		{
			addSObjectType(objectType);
		}
	}

	/**
	 * @description Registers an object type for the unit of work
	 *
	 * @param objectType the type to register
	 */
	public void addSObjectType(SObjectType objectType)
	{
		String objectName = objectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName();
		if(!registeredObjectNames.contains(objectName))
		{
			registeredObjectNames.add(objectName);
			handleRegisterType(objectName);
		}
	}

	/**
	 * @description Will clear all registered updated from the UOW
	 */
	public void clear()
	{
		for(String key : deleteByTypeMap.keySet())
		{
			deleteByTypeMap.get(key).clear();
		}

		for(String key : dirtyByTypeMap.keySet())
		{
			dirtyByTypeMap.get(key).clear();
		}

		for(String key : newListByTypeMap.keySet())
		{
			newListByTypeMap.get(key).clear();
		}

		for(String key : relationshipsMap.keySet())
		{
			relationshipsMap.get(key).relationships.clear();
		}
	}

	/**
	 * @description NA
	 */
	public virtual void onCommitWorkStarting()
	{
	}

	/**
	 * @description NA
	 */
	public virtual void onDMLStarting()
	{
	}

	/**
	 * @description NA
	 */
	public virtual void onDMLFinished()
	{
	}

	/**
	 * @description NA
	 */
	public virtual void onCommitWorkFinishing()
	{
	}

	/**
	 * @description Perform any operation after UOW has performed DML operations
	 *
	 * @param wasSuccessful Indicates if the commit was successful or not
	 */
	@SuppressWarnings('ApexUnusedDeclaration')
	public virtual void onCommitWorkFinished(Boolean wasSuccessful)
	{
	}

	/**
	 * @description Registers the type to be used for DML operations
	 *
	 * @param objectName - The API Name of the object to register
	 */
	private void handleRegisterType(String objectName)
	{
		// add type to dml operation tracking
		newListByTypeMap.put(objectName, new List<SObject>());
		dirtyByTypeMap.put(objectName, new Map<Id, SObject>());
		deleteByTypeMap.put(objectName, new Map<Id, SObject>());
		relationshipsMap.put(objectName, new Relationships());
	}

	/**
	 * @description Method will ensure the correct register method is called based on whether the record  has an ID or not
	 *
	 * @param record The object that was changed
	 */
	public void registerChange(SObject record)
	{
		if(record.Id == null)
		{
			registerNew(record);
		}
		else
		{
			registerDirty(record);
		}
	}

	/**
	 * @description Register a newly created SObject instance to be inserted when commitWork is called
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 */
	public void registerNew(SObject record)
	{
		registerNew(record, null, null);
	}

	/**
	 * @description Register a list of newly created SObject instances to be inserted when commitWork is called
	 *
	 * @param records A list of newly created SObject instances to be inserted during commitWork
	 */
	public void registerNew(List<SObject> records)
	{
		for(SObject record : records)
		{
			registerNew(record);
		}
	}

	/**
	 * @description Register a newly created SObject instance to be inserted when commitWork is called,
	 *   			you may also provide a reference to the parent record instance (should also be registered as new separately)
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
	 */
	public void registerNew(SObject record, SObjectField relatedToParentField, SObject relatedToParentRecord)
	{
		if(record.Id != null)
		{
			throw new UnitOfWorkException(ERROR_ONLY_NEW_RECORDS_CAN_BE_REGISTERED_AS_NEW);
		}

		String objectName = record.getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getName();

		if(!registeredObjectNames.contains(objectName))
		{
			throw new UnitOfWorkException(String.format(ERROR_OBJECT_TYPE_NOT_SUPPORTED, new List<String> {objectName}));
		}

		newListByTypeMap.get(objectName).add(record);

		if(relatedToParentRecord != null && relatedToParentField != null)
		{
			registerRelationship(record, relatedToParentField, relatedToParentRecord);
		}
	}

	/**
	 * @description Register a relationship between two records that have yet to be inserted to the database. This information will be
	 *  			used during the commitWork phase to make the references only when related records have been inserted to the database.
	 *
	 * @param record An existing or newly created record
	 * @param relatedToField A SObjectField reference to the lookup field that relates the two records together
	 * @param relatedTo A SObject instance (yet to be committed to the database)
	 */
	public void registerRelationship(SObject record, SObjectField relatedToField, SObject relatedTo)
	{
		String objectName = record.getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getName();

		if(!registeredObjectNames.contains(objectName))
		{
			throw new UnitOfWorkException(String.format(ERROR_OBJECT_TYPE_NOT_SUPPORTED, new List<String> {objectName}));
		}

		relationshipsMap.get(objectName).add(record, relatedToField, relatedTo);
	}

	/**
	 * @description Register an existing record to be updated during the commitWork method
	 *
	 * @param record An existing record
	 */
	public void registerDirty(SObject record)
	{
		if(record.Id == null)
		{
			throw new UnitOfWorkException(ERROR_NEW_CANNOT_BE_DIRTY);
		}

		String objectTypeName = record.getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getName();

		if(!registeredObjectNames.contains(objectTypeName))
		{
			throw new UnitOfWorkException(String.format(ERROR_OBJECT_TYPE_NOT_SUPPORTED, new List<String> {objectTypeName}));
		}

		dirtyByTypeMap.get(objectTypeName).put(record.Id, record);
	}

	/**
	 * @description Register an existing record to be updated when commitWork is called,
	 *  			 you may also provide a reference to the parent record instance (should also be registered as new separately)
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
	 */
	public void registerDirty(SObject record, SObjectField relatedToParentField, SObject relatedToParentRecord)
	{
		if(record.Id == null)
		{
			throw new UnitOfWorkException(ERROR_NEW_CANNOT_BE_DIRTY);
		}

		String objectTypeName = record.getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getName();

		if(!registeredObjectNames.contains(objectTypeName))
		{
			throw new UnitOfWorkException(String.format(ERROR_OBJECT_TYPE_NOT_SUPPORTED, new List<String> {objectTypeName}));
		}

		dirtyByTypeMap.get(objectTypeName).put(record.Id, record);
		if(relatedToParentRecord != null && relatedToParentField != null)
		{
			registerRelationship(record, relatedToParentField, relatedToParentRecord);
		}
	}

	/**
	 * @description Register a list of existing records to be updated during the commitWork method
	 *
	 * @param records A list of existing records
	 */
	public void registerDirty(List<SObject> records)
	{
		for(SObject record : records)
		{
			registerDirty(record);
		}
	}

	/**
	 * @description Register an existing record to be deleted during the commitWork method
	 *
	 * @param record An existing record
	 */
	public void registerDeleted(SObject record)
	{
		if(record.Id == null)
		{
			throw new UnitOfWorkException(ERROR_NEW_RECORDS_CANNOT_BE_REGISTERED_FOR_DELETION);
		}
		String objectTypeName = record.getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED).getName();

		if(!registeredObjectNames.contains(objectTypeName))
		{
			throw new UnitOfWorkException(String.format(ERROR_OBJECT_TYPE_NOT_SUPPORTED, new List<String> {objectTypeName}));
		}

		deleteByTypeMap.get(objectTypeName).put(record.Id, record);
	}

	/**
	 * @description Register a list of existing records to be deleted during the commitWork method
	 *
	 * @param records A list of existing records
	 */
	public void registerDeleted(List<SObject> records)
	{
		for(SObject record : records)
		{
			registerDeleted(record);
		}
	}

	/**
	 * @description Will check if there are any items to create, edit or delete
	 *
	 * @return Returns true if there are items that are still not committed
	 */
	private Boolean hasItemsToCommit()
	{
		for(Map<Id, SObject> dirtyMap : dirtyByTypeMap.values())
		{
			if(!dirtyMap.values().isEmpty())
			{
				return true;
			}
		}

		for(List<SObject> newList : newListByTypeMap.values())
		{
			if(!newList.isEmpty())
			{
				return true;
			}
		}

		for(Map<Id, SObject> deletedMap : deleteByTypeMap.values())
		{
			if(!deletedMap.values().isEmpty())
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * @description Will perform DML operations required
	 */
	@SuppressWarnings('PMD.ApexSharingViolations')
	private virtual class DBUpdateProxy
	{
		/**
		 * @description will execute insert operation on the provided list
		 *
		 * @param objects list of items
		 */
		protected virtual void doInsert(List<SObject> objects)
		{
			Database.insert(objects, AccessLevel.SYSTEM_MODE);
		}

		/**
		 * @description will execute update operation on the provided list
		 *
		 * @param objects list of items
		 */
		protected virtual void doUpdate(List<SObject> objects)
		{
			Database.update(objects, AccessLevel.SYSTEM_MODE);
		}

		/**
		 * @description will execute delete operation on the provided list
		 *
		 * @param objects list of items
		 */
		protected virtual void doDelete(List<SObject> objects)
		{
			Database.delete(objects, AccessLevel.SYSTEM_MODE);
		}
	}

	/**
	 * @description Will perform DML operations required (without sharing)
	 */
	private without sharing class DBUpdateProxyWithoutSharing extends DBUpdateProxy
	{
		/**
		 * @description will execute insert operation on the provided list
		 *
		 * @param withoutSharingObjects list of items
		 */
		protected override void doInsert(List<SObject> withoutSharingObjects)
		{
			super.doInsert(withoutSharingObjects);
		}

		/**
		 * @description will execute update operation on the provided list
		 *
		 * @param withoutSharingObjects list of items
		 */
		protected override void doUpdate(List<SObject> withoutSharingObjects)
		{
			super.doUpdate(withoutSharingObjects);
		}

		/**
		 * @description will execute delete operation on the provided list
		 *
		 * @param withoutSharingObjects list of items
		 */
		protected override void doDelete(List<SObject> withoutSharingObjects)
		{
			super.doDelete(withoutSharingObjects);
		}
	}

	/**
	 * @description Will perform DML operations required (with sharing)
	 */
	private virtual with sharing class DBUpdateProxyWithSharing extends DBUpdateProxy
	{
		/**
		 * @description will execute insert operation on the provided list
		 *
		 * @param withSharingObjects list of items
		 */
		protected override void doInsert(List<SObject> withSharingObjects)
		{
			super.doInsert(withSharingObjects);
		}

		/**
		 * @description will execute update operation on the provided list
		 *
		 * @param withSharingObjects list of items
		 */
		protected override void doUpdate(List<SObject> withSharingObjects)
		{
			super.doUpdate(withSharingObjects);
		}

		/**
		 * @description will execute delete operation on the provided list
		 *
		 * @param withSharingObjects list of items
		 */
		protected override void doDelete(List<SObject> withSharingObjects)
		{
			super.doDelete(withSharingObjects);
		}
	}

	/**
	 * @description Takes all the work that has been registered with the UnitOfWork and commits it to the database
	 */
	public virtual void commitWork()
	{
		commitWork(null);
	}

	/**
	 * @description Takes all the work that has been registered with the UnitOfWork and commits it to the database
	 *
	 * @param enforceSharing If this property is set to true, when DML operations are performed they will enforce the sharing of the context user
	 * If set to false, it will bypass sharing
	 * If set to null, it will inherit the calling class's sharing settings
	 */
	public virtual void commitWork(Boolean enforceSharing)
	{
		onCommitWorkStarting();

		Boolean wasSuccessful = false;

		Savepoint newSavePoint = hasItemsToCommit() ? Database.setSavepoint() : null;// Wrap the work in its own transaction;
		try
		{
			//Do not do processing below if we don't have items to commit, prevents creation of unnecessary savepoint
			if(!hasItemsToCommit())
			{
				return;
			}

			onDMLStarting();

			DBUpdateProxy dbUpdateProxy;

			//Use sharing of caller
			if(enforceSharing == null)
			{
				dbUpdateProxy = new DBUpdateProxy();
			}
			//Bypass sharing
			else if(enforceSharing == false)
			{
				dbUpdateProxy = new DBUpdateProxyWithoutSharing();
			}
			//enforce sharing
			else
			{
				dbUpdateProxy = new DBUpdateProxyWithSharing();
			}

			// Insert by type
			for(String objectName : registeredObjectNames)
			{
				relationshipsMap.get(objectName).resolve();
				dbUpdateProxy.doInsert(newListByTypeMap.get(objectName));
			}

			// Update by type
			for(String objectName : registeredObjectNames)
			{
				dbUpdateProxy.doUpdate(dirtyByTypeMap.get(objectName).values());
			}

			// Delete by type (in reverse dependency order)
			Integer objectIdx = registeredObjectNames.size() - 1;

			while(objectIdx >= 0)
			{
				dbUpdateProxy.doDelete(deleteByTypeMap.get(registeredObjectNames[objectIdx--]).values());
			}

			// notify we're done with DML
			onDMLFinished();

			// notify we've completed all steps and are in the final stage of completing
			onCommitWorkFinishing();

			wasSuccessful = true;
		}
		catch(Exception error)
		{
			Database.rollback(newSavePoint);

			// Throw exception on to caller
			throw error;
		}
		finally
		{
			// notify we're done with commit work
			onCommitWorkFinished(wasSuccessful);
		}
	}

	/**
	 * @description This class to store the Relationship object
	 */
	private class Relationships
	{
		private final List<Relationship> relationships = new List<Relationship>();

		/**
		 * @description NA
		 */
		public void resolve()
		{
			// Resolve relationships
			for(Relationship relationship : relationships)
			{
				relationship.record.put(relationship.relatedToField, relationship.relatedTo.Id);
			}
		}

		/**
		 * @description To add relationship
		 *
		 * @param record as input
		 * @param relatedToField as input
		 * @param relatedTo as input
		 */
		public void add(SObject record, SObjectField relatedToField, SObject relatedTo)
		{
			Relationship relationship = new Relationship();

			relationship.record = record;
			relationship.relatedTo = relatedTo;
			relationship.relatedToField = relatedToField;

			relationships.add(relationship);
		}
	}

	private class Relationship
	{
		public SObject record;
		public SObject relatedTo;
		public SObjectField relatedToField;
	}

	/**
	 * @description UnitOfWork Exception
	 */
	public class UnitOfWorkException extends Exception
	{
	}
}