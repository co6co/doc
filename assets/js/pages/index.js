document.querySelectorAll('.link0').forEach((el) => {
	el.addEventListener('click', (e) => {
		e.preventDefault();
		const url = el.dataset.url;
		window.open('/pages/fm.html', '_blank');
		setTimeout(() => {
			window.channels.sendMsg({ url: url, title: el.innerText });
		}, 5000);
	});
});
