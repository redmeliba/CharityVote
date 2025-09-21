# CharityVote

CharityVote is a transparent system for community-driven charitable donations and cause prioritization built on the Stacks blockchain. The platform allows users to submit charity causes, vote on them, and distribute donations based on community preferences, ensuring full transparency and decentralization in charitable giving.

## Features

- **Cause Submission**: Community members can submit charitable causes with detailed descriptions
- **Transparent Voting**: Users can vote for causes they support, with all votes recorded on-chain
- **Direct Donations**: Secure STX donations to specific causes with full traceability
- **Automated Distribution**: Funds are distributed directly to verified cause recipients
- **Cause Management**: Creators and contract owners can deactivate causes when necessary
- **Community Governance**: Democratic approach to charity prioritization
- **Real-time Tracking**: Monitor donation amounts, vote counts, and cause status
- **Anti-fraud Protection**: Prevents duplicate voting and ensures proper fund handling

## Technical Specifications

- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity
- **Version**: 1.0.0
- **Clarity Version**: 2
- **Epoch**: 2.5
- **Maximum Causes**: Unlimited (auto-incrementing IDs)
- **Maximum Voters per Cause**: 1,000
- **Voting Period**: ~1 day in blocks (144 blocks)

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) (v16 or higher)
- [Stacks Wallet](https://www.hiro.so/wallet) for mainnet interactions

### Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd CharityVote
   ```

2. Navigate to the contract directory:
   ```bash
   cd CharityVote_contract
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

4. Run tests:
   ```bash
   npm test
   ```

5. Start local development environment:
   ```bash
   clarinet console
   ```

## Usage Examples

### Submit a New Cause

```clarity
(contract-call? .CharityVote submit-cause
  u"Clean Water Initiative"
  u"Providing clean water access to rural communities in developing countries"
  'SP1HTBVD3JG9C05J7HBJTHGR0GGW7KX7KL5Q8NRF)
```

### Vote for a Cause

```clarity
(contract-call? .CharityVote vote-for-cause u1)
```

### Donate to a Cause

```clarity
(contract-call? .CharityVote donate-to-cause u1 u1000000) ;; Donate 1 STX (1,000,000 microSTX)
```

### Distribute Funds

```clarity
(contract-call? .CharityVote distribute-funds u1)
```

### Query Cause Information

```clarity
(contract-call? .CharityVote get-cause u1)
```

## Contract Functions Documentation

### Public Functions

#### `submit-cause`
**Parameters**: `title` (string-utf8 100), `description` (string-utf8 500), `recipient` (principal)
**Returns**: `(response uint uint)`
**Description**: Submits a new charity cause for community voting and donations.

#### `vote-for-cause`
**Parameters**: `cause-id` (uint)
**Returns**: `(response bool uint)`
**Description**: Allows users to vote for a specific cause (one vote per user per cause).

#### `donate-to-cause`
**Parameters**: `cause-id` (uint), `amount` (uint)
**Returns**: `(response bool uint)`
**Description**: Enables users to donate STX to a specific cause.

#### `distribute-funds`
**Parameters**: `cause-id` (uint)
**Returns**: `(response uint uint)`
**Description**: Distributes accumulated donations to the cause recipient.

#### `deactivate-cause`
**Parameters**: `cause-id` (uint)
**Returns**: `(response bool uint)`
**Description**: Deactivates a cause (only callable by contract owner or cause creator).

### Read-Only Functions

#### `get-cause`
**Parameters**: `cause-id` (uint)
**Returns**: Cause details including title, description, votes, and donation amount.

#### `get-user-vote`
**Parameters**: `user` (principal), `cause-id` (uint)
**Returns**: User's voting status for a specific cause.

#### `get-user-donation`
**Parameters**: `user` (principal), `cause-id` (uint)
**Returns**: User's total donation amount for a specific cause.

#### `get-total-donations`
**Returns**: Total amount of donations across all causes.

#### `has-user-voted`
**Parameters**: `user` (principal), `cause-id` (uint)
**Returns**: Boolean indicating if user has voted for the cause.

## Deployment Guide

### Local Deployment (Devnet)

1. Start Clarinet console:
   ```bash
   clarinet console
   ```

2. Deploy the contract:
   ```clarity
   ::deploy_contracts
   ```

### Testnet Deployment

1. Configure testnet settings in `settings/Testnet.toml`
2. Deploy using Clarinet:
   ```bash
   clarinet deployments apply --devnet
   ```

### Mainnet Deployment

1. Update mainnet configuration in `settings/Mainnet.toml`
2. Ensure proper testing on testnet
3. Deploy with verified keys:
   ```bash
   clarinet deployments apply --mainnet
   ```

## Data Structure

### Cause Structure
```clarity
{
  title: (string-utf8 100),
  description: (string-utf8 500),
  recipient: principal,
  creator: principal,
  votes: uint,
  donations-received: uint,
  is-active: bool,
  created-at: uint
}
```

### Error Codes
- `u100`: Owner only operation
- `u101`: Cause not found
- `u102`: User already voted
- `u103`: Insufficient funds
- `u104`: Invalid amount
- `u105`: Cause inactive
- `u106`: Unauthorized access

## Security Notes

### Security Features
- **Access Control**: Only authorized users can deactivate causes
- **Duplicate Prevention**: Users cannot vote multiple times for the same cause
- **Fund Security**: All STX transfers are handled through secure contract functions
- **Input Validation**: All inputs are validated for proper format and length
- **Transparent Operations**: All transactions are recorded on-chain

### Security Considerations
- **Recipient Verification**: Ensure cause recipients are legitimate before donating
- **Contract Auditing**: Consider professional security audits before mainnet deployment
- **Key Management**: Secure private keys for contract deployment and management
- **Rate Limiting**: Monitor for potential spam or abuse of cause submissions
- **Fund Recovery**: No built-in fund recovery mechanism - donations are final

### Best Practices
1. Always verify cause details before voting or donating
2. Check cause activity status before interaction
3. Verify recipient addresses are correct
4. Monitor contract events for transparency
5. Use testnet for initial testing and familiarization

## Development

### Running Tests
```bash
npm test                    # Run all tests
npm run test:report        # Run tests with coverage
npm run test:watch         # Watch mode for development
```

### Contributing
1. Fork the repository
2. Create a feature branch
3. Write comprehensive tests
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the ISC License - see the LICENSE file for details.

## Support

For questions, issues, or contributions, please refer to the project's issue tracker or contact the development team.