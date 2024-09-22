import React, { useState } from 'react';
import styles from './AdminPanel.module.css';

const AdminPanel = ({ contractState, updateContractState }) => {
  const [newGasPrice, setNewGasPrice] = useState('');
  const [newFeePercentage, setNewFeePercentage] = useState('');
  const [tokenToWhitelist, setTokenToWhitelist] = useState('');

  const handleAction = (action) => (e) => {
    e.preventDefault();
    console.log(action, { newGasPrice, newFeePercentage, tokenToWhitelist });
    // Implement blockchain interaction logic here
    // After successful action, update the contract state
    switch (action) {
      case 'updateGasPrice':
        updateContractState({ ...contractState, gasPrice: parseFloat(newGasPrice) });
        break;
      case 'updateFeePercentage':
        updateContractState({ ...contractState, feePercentage: parseFloat(newFeePercentage) });
        break;
      case 'whitelistToken':
        // Implement whitelist logic
        break;
      case 'togglePause':
        updateContractState({ ...contractState, paused: !contractState.paused });
        break;
      case 'withdrawFees':
        updateContractState({ ...contractState, accumulatedFees: 0 });
        break;
      default:
        break;
    }
  };

  return (
    <div className={styles.adminPanel}>
      <h2>Admin Panel</h2>
      <form onSubmit={handleAction('updateGasPrice')} className={styles.form}>
        <h3>Update Gas Price</h3>
        <input
          type="number"
          placeholder="New Gas Price"
          value={newGasPrice}
          onChange={(e) => setNewGasPrice(e.target.value)}
          required
          min="0"
          step="0.1"
        />
        <button type="submit">Update Gas Price</button>
      </form>

      <form onSubmit={handleAction('updateFeePercentage')} className={styles.form}>
        <h3>Update Fee Percentage</h3>
        <input
          type="number"
          placeholder="New Fee Percentage"
          value={newFeePercentage}
          onChange={(e) => setNewFeePercentage(e.target.value)}
          required
          min="0"
          max="100"
          step="0.1"
        />
        <button type="submit">Update Fee Percentage</button>
      </form>

      <form onSubmit={handleAction('whitelistToken')} className={styles.form}>
        <h3>Whitelist Token</h3>
        <input
          type="text"
          placeholder="Token Address"
          value={tokenToWhitelist}
          onChange={(e) => setTokenToWhitelist(e.target.value)}
          required
        />
        <button type="submit">Whitelist Token</button>
      </form>

      <div className={styles.adminActions}>
        <button onClick={handleAction('togglePause')} className={styles.actionButton}>
          {contractState.paused ? 'Unpause Contract' : 'Pause Contract'}
        </button>
        <button onClick={handleAction('withdrawFees')} className={styles.actionButton}>Withdraw Fees</button>
      </div>
    </div>
  );
};

export default AdminPanel;
