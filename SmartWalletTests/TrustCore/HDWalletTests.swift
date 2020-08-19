// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import TrezorCrypto
import XCTest

@testable import Moonkey

class HDWalletTests: XCTestCase {
    let words = "ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal"
    let passphrase = "TREZOR"

    func testSeed() {
        let wallet = HDWallet(mnemonic: words, passphrase: passphrase)
        XCTAssertEqual(wallet.seed.hexString, "7ae6f661157bda6492f6162701e570097fc726b6235011ea5ad09bf04986731ed4d92bc43cbdee047b60ea0dd1b1fa4274377c9bf5bd14ab1982c272d8076f29")
    }

    func testSeedNoPassword() {
        let wallet = HDWallet(mnemonic: words, passphrase: "")
        XCTAssertEqual(wallet.seed.hexString, "354c22aedb9a37407adc61f657a6f00d10ed125efa360215f36c6919abd94d6dbc193a5f9c495e21ee74118661e327e84a5f5f11fa373ec33b80897d4697557d")
    }

    func testDerive() {
        let wallet = HDWallet(mnemonic: words, passphrase: passphrase)
        let key0 = wallet.getKey(at: Ethereum().derivationPath(at: 0))
        let key1 = wallet.getKey(at: Ethereum().derivationPath(at: 1))
        XCTAssertEqual(key0.ethereumAddress, "0x27Ef5cDBe01777D62438AfFeb695e33fC2335979")
        XCTAssertEqual(key1.ethereumAddress, "0x98f5438cDE3F0Ff6E11aE47236e93481899d1C47")
    }

    func testWanchain() {
        let blockchain = Wanchain()
        let wallet = HDWallet(mnemonic: words, passphrase: passphrase)
        let key0 = wallet.getKey(at: blockchain.derivationPath(at: 0))
        XCTAssertEqual(blockchain.address(for: key0.publicKey()).description, "0x4DDa26870B4b3fa3FbA32222159359038f588318")
    }

    

    func testSignHash() {
        let wallet = HDWallet(mnemonic: words, passphrase: passphrase)
        let key = wallet.getKey(at: Ethereum().derivationPath(at: 0))
        let hash = Data(hexString: "3F891FDA3704F0368DAB65FA81EBE616F4AA2A0854995DA4DC0B59D2CADBD64F")!
        let result = Crypto.sign(hash: hash, privateKey: key.data)

        let publicKey = key.publicKey()
        XCTAssertEqual(result.count, 65)
        XCTAssertTrue(Crypto.verify(signature: result, message: hash, publicKey: publicKey.data))
    }

    func testExtendedKeys() {
        let wallet = HDWallet(mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about", passphrase: "")

        let xprv = wallet.getExtendedPrivateKey(for: .bip44, coin: .bitcoin, version: .xprv)
        let xpub = wallet.getExtendedPubKey(for: .bip44, coin: .bitcoin, version: .xpub)

        XCTAssertEqual(xprv, "xprv9xpXFhFpqdQK3TmytPBqXtGSwS3DLjojFhTGht8gwAAii8py5X6pxeBnQ6ehJiyJ6nDjWGJfZ95WxByFXVkDxHXrqu53WCRGypk2ttuqncb")
        XCTAssertEqual(xpub, "xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYJVVhhawA7d4R5WSWGFNbi8Aw6ZRc1brxMyWMzG3DSSSSoekkudhUd9yLb6qx39T9nMdj")

        let yprv = wallet.getExtendedPrivateKey(for: .bip49, coin: .bitcoin, version: .yprv)
        let ypub = wallet.getExtendedPubKey(for: .bip49, coin: .bitcoin, version: .ypub)
        XCTAssertEqual(yprv, "yprvAHwhK6RbpuS3dgCYHM5jc2ZvEKd7Bi61u9FVhYMpgMSuZS613T1xxQeKTffhrHY79hZ5PsskBjcc6C2V7DrnsMsNaGDaWev3GLRQRgV7hxF")
        XCTAssertEqual(ypub, "ypub6Ww3ibxVfGzLrAH1PNcjyAWenMTbbAosGNB6VvmSEgytSER9azLDWCxoJwW7Ke7icmizBMXrzBx9979FfaHxHcrArf3zbeJJJUZPf663zsP")

        let zprv = wallet.getExtendedPrivateKey(for: .bip84, coin: .bitcoin, version: .zprv)
        let zpub = wallet.getExtendedPubKey(for: .bip84, coin: .bitcoin, version: .zpub)
        XCTAssertEqual(zprv, "zprvAdG4iTXWBoARxkkzNpNh8r6Qag3irQB8PzEMkAFeTRXxHpbF9z4QgEvBRmfvqWvGp42t42nvgGpNgYSJA9iefm1yYNZKEm7z6qUWCroSQnE")
        XCTAssertEqual(zpub, "zpub6rFR7y4Q2AijBEqTUquhVz398htDFrtymD9xYYfG1m4wAcvPhXNfE3EfH1r1ADqtfSdVCToUG868RvUUkgDKf31mGDtKsAYz2oz2AGutZYs")
    }

   
}
