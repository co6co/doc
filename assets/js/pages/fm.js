const ele = document.querySelector('#frame');
window.channels.reciveMsg((data) => {
	const url = data.url;
	ele.setAttribute('src', url);
	document.title = data.title;
	document.querySelector('title').innerText = data.title;
});
