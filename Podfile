# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SmartWallet' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SmartWallet
  pod 'Tabman', '~> 2.6'
  pod 'Starscream', '~> 3.1.1'
  pod 'JGProgressHUD'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'MaterialComponents/Snackbar'
  pod 'MaterialComponents/TextFields'
  pod 'TrezorCrypto', '~> 0.0.9', inhibit_warnings: true
  pod 'KeychainAccess', '~> 4.1.0'
  pod 'web3.swift', '~> 0.5.0'
  
  target 'SmartWalletTests' do
    # Pods for testing
    pod 'TrezorCrypto', '~> 0.0.9', inhibit_warnings: true
    pod 'KeychainAccess', '~> 4.1.0'
    pod 'web3.swift', '~> 0.5.0'
    inherit! :search_paths
  end
end
