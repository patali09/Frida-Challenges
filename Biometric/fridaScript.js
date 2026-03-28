Java.perform(function() {
    try {
        var BiometricPrompt = Java.use('android.hardware.biometrics.BiometricPrompt');
        var authenticateMethod = BiometricPrompt.authenticate.overload(
            'android.os.CancellationSignal', 
            'java.util.concurrent.Executor', 
            'android.hardware.biometrics.BiometricPrompt$AuthenticationCallback'
        );

        authenticateMethod.implementation = function(cancellationSignal, executor, callback) {
            var CryptoObject = Java.use('android.hardware.biometrics.BiometricPrompt$CryptoObject');
            var cryptoInstance = CryptoObject.$new(null); 
            var ResultClass = Java.use('android.hardware.biometrics.BiometricPrompt$AuthenticationResult');
            var resultInstance = ResultClass.$new(cryptoInstance, 2);
            callback.onAuthenticationSucceeded(resultInstance);
        };
    } catch (error) {
        console.log("BiometricPrompt not found or hook failed: " + error);
    }
});