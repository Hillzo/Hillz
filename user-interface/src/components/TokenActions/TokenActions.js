import React, { useState } from 'react';
import styles from './TokenActions.module.css';

const TokenActions = ({ contractState, updateContractState }) => {
  const [token, setToken] = useState('');
  const [amount, setAmount] = useState('');
  const [recipient, setRecipient] = useState('');

  const handleAction = (action) => (e) => {
    e.preventDefault();
    console.log(action, { token, amount, recipient });
    // Implement blockchain interaction logic here
    // After successful action, update the contract state
    updateContractState({ ...contractState, accumulatedFees: contractState.accumulatedFees + 10 });
  };

  return (
    <div className={styles.tokenActions}>
      <h2>Token Actions</h2>
      <form onSubmit={handleAction('deposit')} className={styles.form}>
        <h3>Deposit</h3>
        <input
          type="text"
          placeholder="Token Address"
          value={token}
          onChange={(e) => setToken(e.target.value)}
          required
        />
        <input
          type="number"
          placeholder="Amount"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          required
          min="0"
        />
        <button type="submit" disabled={contractState.paused}>Deposit</button>
      </form>

      <form onSubmit={handleAction('withdraw')} className={styles.form}>
        <h3>Withdraw</h3>
        <input
          type="text"
          placeholder="Token Address"
          value={token}
          onChange={(e) => setToken(e.target.value)}
          required
        />
        <input
          type="number"
          placeholder="Amount"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          required
          min="0"
        />
        <button type="submit" disabled={contractState.paused}>Withdraw</button>
      </form>

      <form onSubmit={handleAction('transfer')} className={styles.form}>
        <h3>Transfer</h3>
        <input
          type="text"
          placeholder="Token Address"
          value={token}
          onChange={(e) => setToken(e.target.value)}
          required
        />
        <input
          type="number"
          placeholder="Amount"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          required
          min="0"
        />
        <input
          type="text"
          placeholder="Recipient Address"
          value={recipient}
          onChange={(e) => setRecipient(e.target.value)}
          required
        />
        <button type="submit" disabled={contractState.paused}>Transfer</button>
      </form>
    </div>
  );
};

export default TokenActions;
