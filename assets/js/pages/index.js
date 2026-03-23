document.querySelectorAll('.link0').forEach((el) => {
	el.addEventListener('click', (e) => {
		e.preventDefault();
		const url = el.dataset.url;
		window.open('/pages/fm.html', '_blank');
		window.channels.sendMsg({ url: url, title: el.innerText });
	});
});
