
Xtr = rand(1000,10);
Ytr = rand(1000,1);
Xte = rand(1000,10);
Yte = rand(1000,1);

% Perform default cross validation
[ training_output ] = nytro_train( Xtr , Ytr );

% Perform predictions on the test set and evaluate results
[ prediction_output ] = nytro_test( Xtr , Xte , Yte , training_output);