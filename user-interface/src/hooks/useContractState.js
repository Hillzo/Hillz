import { useState, useEffect } from 'react';

const useContractState = () => {
  const [contractState, setContractState] = useState({
    paused: false,
    gasPrice: 0,
    feePercentage: 0,
    accumulatedFees: 0
  });
  const [isOwner, setIsOwner] = useState(false);

  useEffect(() => {
    // In a real application, you would fetch the contract state from the blockchain
    // and check if the current user is the contract owner
    setContractState({
      paused: false,
      gasPrice: 10,
      feePercentage: 0.1,
      accumulatedFees: 1000
    });
    setIsOwner(true); // For demonstration purposes
  }, []);

  const updateContractState = (newState) => {
    setContractState(newState);
  };

  return { contractState, isOwner, updateContractState };
};

export default useContractState;
