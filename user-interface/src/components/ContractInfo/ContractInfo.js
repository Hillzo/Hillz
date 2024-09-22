import React from 'react';
import styles from './ContractInfo.module.css';

const ContractInfo = ({ contractState }) => {
  return (
    <div className={styles.contractInfo}>
      <h2>Contract Information</h2>
      <div className={styles.infoGrid}>
        <div className={styles.infoItem}>
          <span className={styles.label}>Status:</span>
          <span className={`${styles.value} ${contractState.paused ? styles.paused : styles.active}`}>
            {contractState.paused ? 'Paused' : 'Active'}
          </span>
        </div>
        <div className={styles.infoItem}>
          <span className={styles.label}>Gas Price:</span>
          <span className={styles.value}>{contractState.gasPrice}</span>
        </div>
        <div className={styles.infoItem}>
          <span className={styles.label}>Fee Percentage:</span>
          <span className={styles.value}>{contractState.feePercentage}%</span>
        </div>
        <div className={styles.infoItem}>
          <span className={styles.label}>Accumulated Fees:</span>
          <span className={styles.value}>{contractState.accumulatedFees}</span>
        </div>
      </div>
    </div>
  );
};

export default ContractInfo;
