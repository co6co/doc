window.channels = (function () {
	const chnnelCode = 'msg_channel';
	const channel = new BroadcastChannel(chnnelCode);
	const sendMsg = (data) => {
		//const name = e.target.dataset.name;
		// window.open(`./music.html?name=${name}`,'music')
		channel.postMessage(data);
	};
	const reciveMsg = (callback) => {
		channel.onmessage = (e) => {
			//const data = JSON.stringify(e.data);
			callback(e.data);
		};
	};
	return { sendMsg, reciveMsg };
})();
