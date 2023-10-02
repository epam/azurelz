# Cloud Pipeline development contribution processes

Let's take a look to the contribution process of the **`Azure Landing Zone`** development.

All customer/inner tasks are being presented as separate entities. Each such entity shall have its own **_properties_** - type, description, assignee(s), status(es)/label(s)/mark(s) etc. and **_stages_** - formulation, implementation, testing etc.

## Task entity properties

Any task entity shall be described in details as separate issue. If the task has its subtasks - they can be described in the "parent" issue or as separate issues but linked with their "parent".

General task entity properties:

1. _Type_. Defines the "background" of the task. There are two main task types:
    - **`enhancement`** - for description of new features that shall be added to the Cloud Pipeline functionality
    - **`bug`** - for description bugs/errors found during the Cloud Pipeline usage
2. _Description_. Contains the task description, requirements to implement, technical details, additional data
3. _Assignee(s)_. Defines member(s) of the development team who should implement the functionality described in the task
4. _Label(s)_. Optional properties that can define additional different task attributes - priority/project/state etc. These labels are optional, but could be convenient - e.g., for searching or sorting the tasks

## Life cycle stages of the task entity

Any task should go through the following stages:

- _formulation_
- _development_
- _verification_
- _documenting_
- _closing_

For any task, the flowing of its stages should be reflected - via labels or comments from the developer team members.

### Task formulation

This process is fundamental, from which the task development begins.  
It includes the preparation and writing of the task description and setting of task properties.

_Enhancement_ issue description shall contain, at least:

- title
- clear and detailed description of the task/problem/feature that shall be implemented
- (_if necessary_) technical details of the implementation approach for the development team
- (_if necessary_) images or other documents to clearify the task

_Bug_ issue description shall contain, at least:

- title
- clear and detailed description of what works incorrect and should be fixed
- (_if necessary_) images or other documents to clearify the problem

For any task, should be set the _assignee(s)_ - to define specific member(s) of the development team who will perform the development of that task.

Additionally for the task, labels can be set - for specifying the general version of the **`Azure Landing Zone`**, priority of the task, area of the Platform to which the task belongs, etc.

### Development

After the task creation (formulation), it shall be assigned to one or more members of the development team.  
Then assignee(s) can begin the task implementation. If desired, assignee sets the label about the beginning of the task implementation - **`state/underway`**.  
After the task implementation, assignee should set the corresponding label (**`state/verify`**) and/or leave the comment (_with a link to the code_) which mean that task implementation is finished and the next stages can be started.

### Verification

After the task implementation is done, it shall be verified.  
For that:

- basic functionality is being verified manually (_smoke testing_) with the mandatory comment(s) about results into the task entity
- after that, the testing scenario shall be prepared (_test case(s)_). After the scenario is prepared, scenario author sets the label **`state/has-case`** and leave the comment about that (_with a link to the case(s)_) into the task entity
- if the testing scenario can't be automated - manually testing shall be performed
- if the testing scenario can be automated:
    - automatic tests code shall be developed
    - after automatic tests are prepared, the tests developer sets the label **`state/has-e2e`** and leave the comment about that (_with a link to the test code_) into the task entity
    - automatic tests shall be performed and passed at least once
- info about test results shall be specified into the task entity as comment (_with a link to the results_)

If at any verification step errors are found in the implemented task functionality, the team member leaves the corresponding comment into the task entity. After that the development stage start again - to fix found errors/bugs.  
Then the verification repeats on the corrected task functionality.

### Documenting

After, the documentation on the new functionality shall be prepared.  
At least short description of the functionality shall be added into the version Release Notes.  
If necessary, the full detailed description is being added into the User manual.

After the documentation is prepared, the documents author sets the label **`state/has-doc`** and leave the comment about that (_with a link to the documents_) into the task entity.

### Closing

After the task code is implemented, the implementation of the new functionality/bug fixes is verified, documents are prepared, all necessary comments and labels are set, the task can be closed and considered fully implemented.  
The task author shall set the label **`state/ready`** into the task entity.


***

In general, the whole contribution procedure looks like:

1. Task creation: new issue (title, description, assignees)
2. Task implementation: state labels, pull request(s), comment "_to verify_"
3. Manual testing of the implementation of the base task functionality: comment "_verified_" or errors description and return to step 2
4. Test case(s) creation: new issue (title, description, link to original task, labels)
5. Tests implementation:
    - _manually_ (for non-automated test cases) - testing, comment "_passed_" to the test case issue or errors description to the task issue and return to step 2
    - _automated_ - state labels, pull request(s), comment "_passed_" to the test case issue or errors description to the task issue and return to step 2
6. Test results: test case and test issues are closed, automated test results are being uploaded to the Cloud Pipeline repo, comment "_tests are passed_" to the original task
7. Documentation writing: pull request(s), comment "_docs were updated_" to the original task
8. Task is closed
