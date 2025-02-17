# Imbue Collator

This documentation will cover the below explanation
1) Launching the network: Will explain how you can launch the network locally using the docker configuration with as simple as one step
2) Going through our proposal pallet (our core pallet), explaining the usage step by step

## 1) Launching the network locally

The default compose file automatically launches a local network containing multiple relaychain validators (polkadot nodes) and collators (Imbue collators) which you can interact with using the [browser-based polkadotjs wallet](https://polkadot.js.org/apps/#/explorer). Additionally, docker can be used to launch a collator to supported testnets.
Follow these steps to prepare a local development environment :hammer_and_wrench:

### Setup

1) You will need to [install docker](https://www.docker.com/products/docker-desktop) to launch our pre-built containers
2) Checkout the repository
```bash
git clone --recursive https://github.com/ImbueNetwork/imbue.git

cd imbue
```

### Run

Launch a local network using docker compose:

```bash
docker-compose -f scripts/docker-compose.yml up -d
```

The `scripts` directory contains the docker-compose file which is used to launch the network using a single command. Launching with docker ensures parachains are registered to the relaychain automatically and will begin authoring blocks shortly after launch.  

To ensure your network is functioning properly:  
1) Confirm docker containers are running
```bash
docker ps
``````
- These container names should have a status of 'up':
    - frontend 
    - launch
 
2) Check the container logs
```bash 
docker logs launch
```
- If the network was launched successfully, you will see something similar to this:
![POLKADOT LAUNCH COMPLETE](./assets/imgs/polkadot_launch.png)
```bash 
docker logs frontend
```
- If successful, ```Accepting connections at http://localhost:3001``` will be displayed in the terminal.

### Interacting with your network

To connect to your local network's user interface, visit [polkadot.js](http://localhost:3001/#/explorer) on port 3001. Interacting with your network is detailed [below](#proposal-pallet-interaction)


**NOTE:** If you launched your network using docker or polkadot-launch, your parachains should be automatically registered to the relaychain and you can skip the below two steps and can continue [here](#proposal-pallet-interaction).
   
#### Validate the parachain is registered

1. Verify parathread is registered
   - On custom endpoint 9944, select `Network` -> `Parachains`
   - On the parathreads tab you should see your paraid with a lifecycle status of `Onboarding`
   - After onboarding is complete you will see your parachain registered on the Overview tab
2. Verify parachain is producing blocks
   - Navigate to the collator's custom endpoint 9942
   - Select `Network` -> `Explorer`
   - New blocks are being created if the value of `best` and `finalized` are incrementing higher

## Proposal Pallet interaction

Our proposal pallet consists of our core logic and facilitates the implementation through extrinsics (extrinsics can be thought of functions that can be called from outside, in this case from the frontend). 

The crowdfunding of a project basically comprises of 6 steps from the submission of the proposal to withdrawing of the fund. Alternatively, the individual or team can decide to withdraw their projects proposal as well. 
The flow of creating a proposal and getting funded is shown below step by step using screenshots. You can follow along the same either using polkadotjs apps or the frontend (localhost:3001) that comes with our docker compose

1) Creating a project: The first step is to create the project, i.e. submitting the proposal, the given signature of the extrinsic is shown below. From the UI select the pallet which is our imbueProposals pallet and then select the function below.

  ```javascript
  create_project(origin: OriginFor<T>, name: Vec<u8>, logo: Vec<u8>, description: Vec<u8>, website: Vec<u8>, proposed_milestones: Vec<ProposedMilestone>, required_funds: BalanceOf<T>)
  ```

  To create a project we need to pass the following parameters
  
    - Origin: This is the account trying to call the extrinsic
    - name: Name of the project you want to submit the proposal for
    - logo: logo for the project
    - description: description of the project 
    - website: provide the website of your project
    - proposed_milestones: its list of milestones you want to add with each milestone having name and percentage allocated to it
    - requiredFunds: amount requested for funding

please find the screenshot attached for the extrinsic call
   ![create project ](./assets/imgs/create_project.png)
  
2) Scheduling the round: Once the proposal for the project is submitted, the next step is to schedule the round for milestones.From the UI select the our imbueProposals pallet and then select the function below.

    ```javascript
    schedule_round(origin: OriginFor<T>, start: T::BlockNumber, end: T::BlockNumber, project_key: ProjectIndex, milestone_indexes: Vec<MilestoneIndex>)
    ```
   
  To schedule a round for milestone/s we need to pass the following parameters to the extrinsics

    - Origin: This is the account trying to call the extrinsic
    - start : We need to pass the block number from when the round is valid and make sure it should be greater than the current block 
    - end: We need to pass the blocknumber till when the round should be valid for the given milestone/s. This number should be greater than both start number and the current block.
    - project_key: This is basically a unique key that act as your project index
    - milestone_indexes: The milestones need to be included in the round

  please find the screenshot attached for the extrinsic call
   ![schedule round ](./assets/imgs/schedule_round.png)

3) Contributing to the project: Using this extrinsic, the community can contribute to the proposals they think have good potential.From the UI select the our imbueProposals pallet and then select the function below.  
   
  ```javascript
  contribute(origin: OriginFor<T>, project_key: ProjectIndex, value: BalanceOf<T>)
  ```

  To contribute to the proposal we need to pass the following parameters to the extrinsics

    - Origin: This is the account trying to call the extrinsic
    - project_key: unique key that act as your project index
    - value: the value they want to contribute to the proposal

  please find the screenshot attached for the extrinsic call
   ![contribute ](./assets/imgs/contribute.png)
 

4) Vote on a specific milestone: This extrinsic allows community members to vote for specific milestone for a given proposal. They can either approve or disapprove by passing yes or no. From the UI select the our imbueProposals pallet and then select the function below. 

 ```javascript
  vote_on_milestone(origin: OriginFor<T>, project_key: ProjectIndex, milestone_index: MilestoneIndex, approve_milestone: bool)
  ```

  To vote on a milestone we need to pass the following parameters to the extrinsic

    - Origin: This is the account trying to call the extrinsic
    - project_key: unique key that act as your project index
    - milestone_indexe: The milestone which you want to vote for
    - approve_milestone: either yes or no

  please find the screenshot attached for the extrinsic call
   ![vote on milestone ](./assets/imgs/vote_milestone.png)

 5) Approve the project proposal: This extrinsic is called to approve a project proposal with the milestones that is being approved. From the UI select the our imbueProposals pallet and then select the function below. 

  ```javascript
   approve(origin: OriginFor<T>, round_index: RoundIndex, project_key: ProjectIndex, milestone_indexes:  Vec<MilestoneIndex>)
  ```
    
  To approve a project we need to pass the following parameters

    - Origin: This is the account trying to call the extrinsic
    - RoundIndex: the scheduled round's index
    - project_key: unique key that act as your project index
    - milestone_indexes: The list of milestones which you want to approve
  
  please find the screenshot attached for the extrinsic call
   ![approve a project ](./assets/imgs/approve_project.png)
