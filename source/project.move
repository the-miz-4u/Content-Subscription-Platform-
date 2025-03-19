module MyModule::ContentSubscription {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a creator.
    struct Creator has store, key {
        subscription_fee: u64,  // Fee required to subscribe to the creator
        total_earnings: u64,    // Total earnings from subscriptions
    }

    /// Function for creators to register with a subscription fee.
    public fun register_creator(creator: &signer, subscription_fee: u64) {
        assert!(subscription_fee > 0, 0); // Subscription fee must be greater than 0
        let creator_address = signer::address_of(creator);
        let creator_info = Creator {
            subscription_fee,
            total_earnings: 0,
        };
        move_to(creator, creator_info);
    }

    /// Function for subscribers to pay the creator's subscription fee.
    public fun subscribe(subscriber: &signer, creator_address: address) acquires Creator {
        let creator = borrow_global_mut<Creator>(creator_address);
        let subscription_fee = creator.subscription_fee;

        // Transfer the subscription fee from the subscriber to the creator
        let payment = coin::withdraw<AptosCoin>(subscriber, subscription_fee);
        coin::deposit<AptosCoin>(creator_address, payment);

        // Update the creator's total earnings
        creator.total_earnings = creator.total_earnings + subscription_fee;
    }
}
