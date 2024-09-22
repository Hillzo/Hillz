import React from 'react';
import Header from './components/Header/Header';
import ContractInfo from './components/ContractInfo/ContractInfo';
import TokenActions from './components/TokenActions/TokenActions';
import AdminPanel from './components/AdminPanel/AdminPanel';
import useContractState from './hooks/useContractState';
import styles from './App.module.css';

const App = () => {
  const { contractState, isOwner, updateContractState } = useContractState();

  return (
    <div className={styles.app}>
      <Header />
      <main className={styles.main}>
        <div className={styles.leftColumn}>
          <ContractInfo contractState={contractState} />
          <TokenActions contractState={contractState} updateContractState={updateContractState} />
        </div>
        <div className={styles.rightColumn}>
          {isOwner && <AdminPanel contractState={contractState} updateContractState={updateContractState} />}
        </div>
      </main>
    </div>
  );
};

export default App;
