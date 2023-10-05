/**
 * @description Copyright 2020 Google LLC
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * https://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @see https ://github.com/mitchspano/apex-trigger-actions-framework/blob/master/README.md#metadata-driven-trigger-actions¬
 */
public inherited sharing class CMN_TRA_Interfaces
{
	public interface CMN_INT_BeforeInsert
	{
		void beforeInsert(List<SObject> newList);
	}

	public interface CMN_INT_AfterInsert
	{
		void afterInsert(List<SObject> newList);
	}

	public interface CMN_INT_BeforeUpdate
	{
		void beforeUpdate(List<SObject> newList, List<SObject> oldList);
	}

	public interface CMN_INT_AfterUpdate
	{
		void afterUpdate(List<SObject> newList, List<SObject> oldList);
	}

	public interface CMN_INT_BeforeDelete
	{
		void beforeDelete(List<SObject> oldList);
	}

	public interface CMN_INT_AfterDelete
	{
		void afterDelete(List<SObject> oldList);
	}

	public interface CMN_INT_AfterUndelete
	{
		void afterUndelete(List<SObject> newList);
	}
}