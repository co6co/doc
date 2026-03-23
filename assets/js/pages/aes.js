(function () {
	function textToBinaryUTF8(text) {
		const encoder = new TextEncoder();
		const data = encoder.encode(text);
		return Array.from(data).map((byte) => byte.toString(16).padStart(8, '0x'));
	}
	// ASE 加密
	const asePwd = '123456';
	data = sjcl.encrypt(asePwd, '你好,世界！');
	console.info('ase encrypted: ', data);
	const data_decrypted = sjcl.decrypt(asePwd, data);
	console.info('ase decrypted: ', data_decrypted);
	// end ASE 加密

	const key0 = document.getElementById('key0');
	const key1 = document.getElementById('key1');

	const crypt = new JSEncrypt();
	const privateKey = crypt.getPrivateKey();
	key0.value = privateKey;
	key1.value = crypt.getPublicKey();
	/*
        crypt.setPrivateKey(privateKey);
        console.info("私钥", privateKey)
        const encryptKey = crypt.encrypt("你好");
        console.log("encryptKey: " + encryptKey);
        const decrypted = crypt.decrypt(encryptKey);
        console.log("decrypted: " + decrypted);
        console.info("公钥", crypt.getPublicKey())
        */

	const privateDencrypt = function (key, content, isPrivateKey) {
		crypt.setPrivateKey(key);
		return crypt.decrypt(content);
	};
	const publicEncrypt = function (key, content) {
		crypt.setPublicKey(key);
		return crypt.encrypt(content);
	};

	const privateSign = function (key, content) {
		crypt.setPrivateKey(key);
		return crypt.sign(content);
	};
	const publicVerify = function (key, content, sign) {
		console.info(key, content, sign);
		crypt.setPublicKey(key);
		return crypt.verify(content, sign);
	};
	const aseEncrypt = function (key, content) {
		return sjcl.encrypt(key, content);
	};
	const aseDecrypt = function (key, content) {
		return sjcl.decrypt(key, content);
	};
	const getContent = () => {
		return document.getElementById('content').value;
	};
	const getEnContent = () => {
		return document.getElementById('encontent').value;
	};
	const getKey0 = (contentId) => {
		const key = key0.value.trim();

		if (!key.startsWith('-----BEGIN RSA PRIVATE KEY-----'))
			console.warn('不是私钥格式');

		return key;
	};
	const getKey1 = (contentId) => {
		const key = key1.value.trim();
		let isPrivateKey = false;
		if (!key.startsWith('-----BEGIN PUBLIC KEY-----')) {
			console.warn('不是公钥格式');
		}
		return key;
	};

	const encryptBtn = document.getElementById('encryptbtn');
	const decryptBtn = document.getElementById('decryptbtn');
	const signBtn = document.getElementById('signbtn');
	const verifyBtn = document.getElementById('verifybtn');

	contentEle = document.getElementById('content');
	encontentEle = document.getElementById('encontent');

	encryptBtn.addEventListener('click', () => {
		const publicKey = getKey1();
		const content = getContent();
		encontentEle.value = publicEncrypt(publicKey, content);
	});
	decryptBtn.addEventListener('click', () => {
		const privateKey = getKey0();
		const content = getEnContent();
		contentEle.value = privateDencrypt(privateKey, content);
	});

	signBtn.addEventListener('click', () => {
		const privateKey = getKey0();
		const content = getContent();
		encontentEle.value = privateSign(privateKey, content);
	});
	verifyBtn.addEventListener('click', () => {
		const publicKey = getKey1();
		const content = getContent();
		const sign = getEnContent();
		alert('验证结果：' + publicVerify(publicKey, content, sign));
	});
})();
