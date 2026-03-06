---
description: Devise various Jira tickets such as User Stories, Tasks, Bugs, Spikes, and more. Utilize for adherence to Agile principles and best practices at Skillshare and expected work planning practices.
---

## When to Use

- When planning out trackable upcoming work
- When the agent or user require Jira tickets
- When interacting with Jira

## Jira Planning

There are multiple types of Jira issues that I work with:

- Epic: Encapsulates multiple tickets that should take more than 1 sprint
- User Story: Feature work
- Task: Technical work
- Bug: An issue with the product or system
- Spike: Investigative work to reduce ambiguity in future tickets

## Epic tickets

An epic ticket represents a large-scale project or initiative that spans multiple sprints.

It is used as an umbrella (parent) ticket which will involve smaller, more manageable pieces, typically as user story ticket, but sometimes tasks, spikes, etc. as necessary to research and implement the feature(s).

## User Story tickets

A user story ticket represents a feature request or enhancement that needs to be implemented.

The ticket should be framed from the perspective of the user who will benefit from the feature, hence the _user_ story.

A user story is typically framed from an end-user perspective, but could be utilized for certain internal perspectives as well (e.g. as a developer...).

Note: In certain cases, you may want to utilize a task to constitute the work. See the task ticket type for more information.

The following template represents USER STORY requirements:

```
## User Story

As a [members/teachers/internal users](who wants to accomplish something)
I want to (what they want to accomplish)
So that (why they want to accomplish that thing)

## Description

## Acceptance Criteria

Feature 1:

Scenario 1:

Given...

When...

Then...

## Examples

## Functional Outcomes
Eventing
UAT Testing
Localization
a11y
Experimentation / Rollout Plan
Xfunctional awareness / signoff
```

## Bug tickets

A bug ticket constitutes a misbehavior of the system that has been reported either internally or by customers.

It is important to capture who reported the bug, its details, and the steps to reproduce the issue.

The following template represents BUG requirements:

```
## High Level Description
Example: We have identified a bug in [system], which is impacting [members/teachers/internal users].

## Operating System / Browser / App Version
[Describe the systems and/or versions this bug was found on]

## Steps to Reproduce
[Step 1]
[Step 2]

## Actual Behavior
[Describe the issue in detail, including what is happening and where]

## Expected Behavior
[Describe what should be happening instead]

## Customer(s) Impacted
[Provide details on which users are impacted by this issue, and the potential business impact]

## Part of the Software Impacted
[Identify which part of the system is impacted by the bug (e.g. Login, Admin, Class Details, etc.)]

## Attachments
[Add any relevant screenshots or log files to help identify the issue]
```

## Task tickets

A task ticket represents a technical task to be completed. It is used to break down larger tasks into smaller, more manageable pieces. It should not be preferred over a user story ticket unless there is a compelling reason to do so.

Common use cases for task tickets include:

- Technical elements of an epic that constitute foundational work separate from a feature.
- Updating documentation or code comments

There is no template for TASK tickets. They are open-ended technical breakdowns of work to do. These should still include a Definition of Done.

## Spike tickets

A spike ticket represents a short-term investigation into a problem or opportunity. It is used to gather information and make a decision about the best course of action.

There is no template for spike tickets. This is simply a description of the research / PoC / etc to be done and the benefits.

The expected outcomes of the spike ticket should be clearly defined along with or within a Definition of Done.
