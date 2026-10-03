# 🗳️ Voting Smart Contract

A simple and transparent **Voting / Proposal Management Smart Contract** written in **Solidity**.

This contract allows users to:

* Create proposals
* Set a voting duration for each proposal
* Vote **Yes** or **No**
* Prevent an address from voting more than once on the same proposal
* Check the current voting results
* Track the proposal creator and timestamps

The contract is designed as a simple educational example for understanding **Solidity structs, mappings, arrays, timestamps, and voting logic**.

---

## 📌 Features

### Proposal Creation

Any address can create a new proposal by providing:

* Proposal name
* Proposal description
* Voting duration in minutes

The contract automatically stores:

* Creator address
* Creation timestamp
* End timestamp
* Yes vote count
* No vote count

---

### 🗳️ Voting

Users can vote on an existing proposal with either:

```text
Yes
```

or

```text
No
```

Each address can vote **only once per proposal**.

If an address has already voted, another vote will be rejected.

---

### ⏱️ Voting Deadline

Each proposal has an `endTime`.

Users can vote only while:

```solidity
block.timestamp < proposal.endTime
```

Once the voting period has ended, additional votes are rejected.

---

### 📊 Result Tracking

The contract stores two counters for every proposal:

```solidity
yesVotes
noVotes
```

The `getResult()` function can be used to retrieve the current results.

---

# 🛠️ Technology

* **Solidity:** `^0.8.34`
* **Smart Contract:** Ethereum-compatible blockchain
* **License:** MIT

The contract can be deployed on Ethereum or compatible EVM networks such as:

* Ethereum
* Sepolia
* Polygon
* BNB Smart Chain
* Arbitrum
* Optimism
* Other EVM-compatible networks

> Network availability and deployment configuration depend on the tools and wallet being used.

---

# 📁 Contract Structure

The main contract is:

```solidity
contract Voting
```

It contains the following main components:

```text
Voting
│
├── Proposal struct
│   ├── name
│   ├── description
│   ├── creator
│   ├── endTime
│   ├── createTime
│   ├── yesVotes
│   ├── noVotes
│   └── hasVoted
│
├── proposals[]
│
├── addProposal()
├── vote()
└── getResult()
```

---

# 🧱 Proposal Structure

Each proposal is represented by the following struct:

```solidity
struct Proposal {
    string name;
    string description;
    address creator;
    uint endTime;
    uint createTime;
    uint yesVotes;
    uint noVotes;
    mapping(address => bool) hasVoted;
}
```

## Fields

### `name`

The name or title of the proposal.

Example:

```text
"Should we launch the new product?"
```

---

### `description`

A detailed description of the proposal.

Example:

```text
"Vote on whether the company should launch the new product this month."
```

---

### `creator`

The Ethereum address that created the proposal.

It is automatically assigned using:

```solidity
proposal.creator = msg.sender;
```

---

### `createTime`

The timestamp at which the proposal was created.

It is stored using:

```solidity
proposal.createTime = block.timestamp;
```

---

### `endTime`

The timestamp at which voting ends.

It is calculated when the proposal is created.

---

### `yesVotes`

Number of users who voted:

```text
YES
```

---

### `noVotes`

Number of users who voted:

```text
NO
```

---

### `hasVoted`

A mapping used to determine whether an address has already voted.

```solidity
mapping(address => bool) hasVoted;
```

For example:

```text
0x123...abc → true
0x456...def → false
```

This prevents the same address from voting multiple times on the same proposal.

---

# 📦 Proposals Array

All proposals are stored inside:

```solidity
Proposal[] public proposals;
```

Each proposal has an index.

For example:

```text
Proposal 0
Proposal 1
Proposal 2
Proposal 3
```

The first proposal has index:

```text
0
```

The second:

```text
1
```

And so on.

Because the array is declared as `public`, Solidity automatically generates a getter for its publicly accessible fields.

However, because `Proposal` contains a mapping, the automatically generated getter does not expose the entire proposal including the `hasVoted` mapping.

---

# ➕ Creating a Proposal

A new proposal can be created with:

```solidity
function addProposal(
    string memory _name,
    string memory _description,
    uint _durationInMinutes
) public
```

## Parameters

| Parameter            | Type     | Description                |
| -------------------- | -------- | -------------------------- |
| `_name`              | `string` | Proposal name              |
| `_description`       | `string` | Proposal description       |
| `_durationInMinutes` | `uint`   | Voting duration in minutes |

---

## Example

```solidity
addProposal(
    "Launch New Product",
    "Should the company launch the new product?",
    30
);
```

This creates a proposal with a voting duration based on the provided value.

---

# 🔍 How `addProposal()` Works

The contract first creates a new element inside the `proposals` array:

```solidity
Proposal storage proposal = proposals.push();
```

Then it stores the proposal information:

```solidity
proposal.name = _name;
proposal.description = _description;
proposal.creator = msg.sender;
```

The creation time is recorded:

```solidity
proposal.createTime = block.timestamp;
```

The vote counters are initialized:

```solidity
proposal.yesVotes = 0;
proposal.noVotes = 0;
```

---

# 🗳️ Voting

Users can vote using:

```solidity
function vote(
    uint _proposalIndex,
    bool _yesVote
) public
```

## Parameters

| Parameter        | Type   | Description                    |
| ---------------- | ------ | ------------------------------ |
| `_proposalIndex` | `uint` | Index of the proposal          |
| `_yesVote`       | `bool` | `true` for Yes, `false` for No |

---

## YES Vote

To vote Yes:

```solidity
vote(0, true);
```

The contract executes:

```solidity
proposal.yesVotes += 1;
```

---

## NO Vote

To vote No:

```solidity
vote(0, false);
```

The contract executes:

```solidity
proposal.noVotes += 1;
```

---

# 🔐 Preventing Multiple Votes

Before accepting a vote, the contract checks:

```solidity
require(
    !proposal.hasVoted[msg.sender],
    "You have already voted before"
);
```

If the address has already voted, the transaction is reverted.

After a successful vote:

```solidity
proposal.hasVoted[msg.sender] = true;
```

This means the same wallet cannot vote twice on the same proposal.

### Important

The restriction is **per proposal**, not global.

For example:

```text
User A
 ├── Proposal 0 → voted
 ├── Proposal 1 → can vote
 └── Proposal 2 → can vote
```

A user can vote once on every different proposal.

---

# ⏰ Voting Deadline

Before accepting a vote, the contract checks:

```solidity
require(
    block.timestamp < proposal.endTime,
    "The time has finished"
);
```

Therefore, voting is only possible while:

```text
current timestamp < endTime
```

Once:

```text
current timestamp >= endTime
```

the vote transaction will revert.

---

# 📊 Getting Voting Results

The current results can be retrieved using:

```solidity
function getResult(
    uint _proposalIndex
)
public
view
returns (
    uint _yesVotes,
    uint _noVotes
)
```

Example:

```solidity
getResult(0);
```

Possible result:

```text
YES: 15
NO: 7
```

The function returns:

```solidity
(
    proposal.yesVotes,
    proposal.noVotes
)
```

---

# 🚫 Proposal Validation

Before voting or getting results, the contract verifies that the proposal exists:

```solidity
require(
    _proposalIndex < proposals.length,
    "proposal is not exist"
);
```

For example, if there are only:

```text
3 proposals
```

valid indexes are:

```text
0
1
2
```

Calling:

```solidity
vote(3, true);
```

will revert because proposal `3` does not exist.

---

# 🔄 Voting Flow

The overall process looks like this:

```text
User
 │
 │
 ▼
Create Proposal
 │
 ▼
Proposal Stored
 │
 ├── Creator
 ├── Name
 ├── Description
 ├── Create Time
 ├── End Time
 ├── YES = 0
 └── NO = 0
 │
 ▼
Voting Period
 │
 ├───────────────┐
 │               │
 ▼               ▼
YES             NO
 │               │
 ▼               ▼
yesVotes++      noVotes++
 │               │
 └───────┬───────┘
         │
         ▼
   Mark Address
   as Voted
         │
         ▼
   Voting Ends
         │
         ▼
    Get Results
```

---

# 🔒 Security Checks

The contract currently includes several basic validation checks.

### 1. Proposal Exists

```solidity
require(
    _proposalIndex < proposals.length,
    "proposal is not exist"
);
```

---

### 2. User Has Not Already Voted

```solidity
require(
    !proposal.hasVoted[msg.sender],
    "You have already voted before"
);
```

---

### 3. Voting Period Is Still Active

```solidity
require(
    block.timestamp < proposal.endTime,
    "The time has finished"
);
```

These checks prevent basic invalid interactions with the contract.

---

# ⚠️ Important Implementation Note

The current code contains this line:

```solidity
proposal.endTime =
    block.timestamp + (_durationInMinutes + 1 minutes);
```

This deserves attention.

`_durationInMinutes` is a plain integer, while:

```solidity
1 minutes
```

is a Solidity time unit equal to 60 seconds.

Because of Solidity's unit handling, adding the integer directly to `1 minutes` does **not** convert `_durationInMinutes` into minutes.

If the intention is:

> `_durationInMinutes` represents the number of minutes that voting should remain open.

then the clearer implementation is:

```solidity
proposal.endTime =
    block.timestamp + (_durationInMinutes * 1 minutes);
```

For example:

```solidity
_durationInMinutes = 30
```

should result in approximately:

```text
30 minutes
```

of voting time.

If the `+ 1 minute` was intentional, it can be written explicitly:

```solidity
proposal.endTime =
    block.timestamp + (_durationInMinutes * 1 minutes) + 1 minutes;
```

---

# 💡 Example

Suppose a user creates:

```solidity
addProposal(
    "Community Proposal",
    "Should we add a new feature?",
    60
);
```

The intended behavior is:

```text
Proposal created
       │
       ▼
60-minute voting period
       │
       ├── User A → YES
       ├── User B → YES
       ├── User C → NO
       └── User D → YES
       │
       ▼
Voting ends
       │
       ▼
Result:
YES = 3
NO  = 1
```

---

# 🧪 Testing

The contract can be tested using development environments such as:

* Remix IDE
* Hardhat
* Foundry
* Other Ethereum development frameworks

For a quick test, Remix is sufficient.

---

# 🚀 Deploying with Remix

## 1. Open Remix

Open:

[Remix IDE](https://remix.ethereum.org/?utm_source=chatgpt.com)

---

## 2. Create the Contract

Create a file:

```text
Voting.sol
```

Paste the contract code into the file.

---

## 3. Compile

Open:

```text
Solidity Compiler
```

Select a compatible compiler version for:

```solidity
pragma solidity ^0.8.34;
```

Then click:

```text
Compile Voting.sol
```

---

## 4. Deploy

Go to:

```text
Deploy & Run Transactions
```

Select the appropriate environment.

For testing, you can use a local Remix VM.

For a real testnet/mainnet deployment, connect a compatible wallet and select the desired network.

---

# 🧪 Example Test

After deployment:

### Step 1 — Create Proposal

Call:

```text
addProposal
```

with:

```text
_name:
Should we launch the project?

_description:
Community members can vote on the project launch.

_durationInMinutes:
10
```

---

### Step 2 — Check Proposal

The proposal will be stored at index:

```text
0
```

---

### Step 3 — Vote YES

Call:

```text
vote(0, true)
```

Result:

```text
YES = 1
NO = 0
```

---

### Step 4 — Change Account

Connect another wallet/account and call:

```text
vote(0, false)
```

Result:

```text
YES = 1
NO = 1
```

---

### Step 5 — Try Voting Again

Using the first account, try:

```text
vote(0, true)
```

The transaction should fail with:

```text
You have already voted before
```

---

### Step 6 — Get Results

Call:

```text
getResult(0)
```

Expected result:

```text
YES = 1
NO = 1
```

---

# 🧩 Full Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract Voting {
    struct Proposal {
        string name;
        string description;
        address creator;
        uint endTime;
        uint createTime;
        uint yesVotes;
        uint noVotes;
        mapping(address => bool) hasVoted;
    }

    Proposal[] public proposals;

    function addProposal(
        string memory _name,
        string memory _description,
        uint _durationInMinutes
    ) public {
        Proposal storage proposal = proposals.push();

        proposal.name = _name;
        proposal.description = _description;
        proposal.creator = msg.sender;
        proposal.createTime = block.timestamp;

        proposal.endTime =
            block.timestamp +
            (_durationInMinutes + 1 minutes);

        proposal.yesVotes = 0;
        proposal.noVotes = 0;
    }

    function vote(
        uint _proposalIndex,
        bool _yesVote
    ) public {
        require(
            _proposalIndex < proposals.length,
            "proposal is not exist"
        );

        Proposal storage proposal = proposals[_proposalIndex];

        require(
            !proposal.hasVoted[msg.sender],
            "You have already voted before"
        );

        require(
            block.timestamp < proposal.endTime,
            "The time has finished"
        );

        if (_yesVote) {
            proposal.yesVotes += 1;
        } else {
            proposal.noVotes += 1;
        }

        proposal.hasVoted[msg.sender] = true;
    }

    function getResult(
        uint _proposalIndex
    )
        public
        view
        returns (
            uint _yesVotes,
            uint _noVotes
        )
    {
        require(
            _proposalIndex < proposals.length,
            "proposal is not exist"
        );

        Proposal storage proposal = proposals[_proposalIndex];

        return (
            proposal.yesVotes,
            proposal.noVotes
        );
    }
}
```

---

# 🔮 Possible Improvements

This contract is a good starting point, but a production-ready voting system could be expanded with additional functionality.

Possible improvements include:

* [ ] Emit events when a proposal is created
* [ ] Emit events when someone votes
* [ ] Add a function to retrieve proposal information
* [ ] Add a function to retrieve the total number of proposals
* [ ] Add proposal status: `Active`, `Ended`
* [ ] Add minimum/maximum voting duration
* [ ] Prevent zero-minute proposals
* [ ] Add proposal cancellation
* [ ] Allow only specific addresses to create proposals
* [ ] Add voting power based on token ownership
* [ ] Use OpenZeppelin access-control mechanisms
* [ ] Add a frontend with React/Next.js
* [ ] Display live voting results
* [ ] Connect the frontend to MetaMask
* [ ] Add automated tests
* [ ] Deploy to an EVM testnet
* [ ] Add event indexing for frontend applications

---

# 📡 Suggested Events

For a more production-friendly version, events could be added:

```solidity
event ProposalCreated(
    uint indexed proposalIndex,
    string name,
    address indexed creator,
    uint endTime
);

event Voted(
    uint indexed proposalIndex,
    address indexed voter,
    bool yesVote
);
```

This would make it easier for a frontend or indexing service to track proposal creation and votes.

---

# ⚠️ Limitations

This contract is intentionally simple and should be considered an **educational implementation** rather than a production-ready governance system.

Important limitations include:

### One Wallet = One Vote

Voting is based on:

```solidity
msg.sender
```

Therefore, the contract prevents one Ethereum address from voting twice, but it does not establish that one real-world person corresponds to one address.

---

### No Token-Based Voting

Every address has exactly one vote.

There is currently no voting power based on:

* Token balance
* NFT ownership
* DAO membership
* Stake
* Reputation

---

### No Proposal Management

After creation, proposals cannot currently be:

* Edited
* Cancelled
* Deleted

---

### No Final Result State

The contract does not explicitly store a final state such as:

```text
PASSED
REJECTED
TIE
```

The result can instead be calculated from:

```solidity
yesVotes
noVotes
```

---

# 📄 License

This project is licensed under the MIT License.

```text
MIT License
```

You are free to use, modify, and distribute the code according to the terms of the MIT License.

---

# 👨‍💻 Author

Created as a Solidity / Blockchain learning project.

The contract demonstrates fundamental Solidity concepts including:

```text
Structs
Mappings
Dynamic Arrays
Storage
msg.sender
block.timestamp
require()
View Functions
Boolean Voting
Time-based Logic
```

---

# ⭐ Learning Goals

By studying this contract, you can learn how to implement:

1. A Solidity `struct`
2. A dynamic array of structs
3. A mapping inside a struct
4. User-specific state
5. `msg.sender`
6. `block.timestamp`
7. `require()` validation
8. Time-based conditions
9. Basic voting logic
10. Read-only functions with `view`
11. Returning multiple values
12. Basic smart-contract architecture

---

## 📌 Summary

The `Voting` contract provides a simple decentralized voting mechanism where users can create proposals and vote on them.

The core workflow is:

```text
Create Proposal
       ↓
Set Voting Duration
       ↓
Users Vote
       ↓
Prevent Duplicate Votes
       ↓
Voting Period Ends
       ↓
Read YES / NO Results
```

It is a compact example for learning the fundamentals of **Solidity and EVM-based smart contracts** and can later be extended into a complete DAO/governance application.
