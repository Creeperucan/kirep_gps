document.addEventListener('DOMContentLoaded', () => {
    const inputBox = document.getElementById('inputBox');
    const button1 = document.getElementById('button1');
    const button2 = document.getElementById('button2');
    const container = document.querySelector('.container');

    button1.addEventListener('click', () => {
        const inputValue = inputBox.value;
        container.style.display = 'none';

        fetch(`https://kirep-gps/openGPS`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8'
            },
            body: JSON.stringify({
                action: 'button1',
                value: inputValue
            })
        });

        fetch(`https://kirep-gps/closeMenu`, {
            method: 'POST'
        });
    });

    button2.addEventListener('click', () => {
        container.style.display = 'none';

        fetch(`https://kirep-gps/closeGPS`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8'
            },
            body: JSON.stringify({
                action: 'button2'
            })
        });

        fetch(`https://kirep-gps/closeMenu`, {
            method: 'POST'
        });
    });

    window.addEventListener('message', (event) => {
        if (event.data.type === 'openMenu') {
            container.style.display = 'flex';
        }
    });
});
