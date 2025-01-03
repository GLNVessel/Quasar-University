window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === 'loginMenu') {
        document.getElementById('loginMenu').style.display = 'block';
    } else if (data.action === 'openMenu') {
        document.getElementById('bankMenu').style.display = 'block';
        document.getElementById('balance').textContent = `Account Balance: $${data.balance}`;
        document.getElementById('cash').textContent = `Cash: $${data.cash}`;
    } else if (data.action === 'updateMenu') {
        document.getElementById('balance').textContent = `Account Balance: $${data.balance}`;
        document.getElementById('cash').textContent = `Cash: $${data.cash}`;
    }
});

document.getElementById('login').addEventListener('click', () => {
    // Hide the login menu
    document.getElementById('loginMenu').style.display = 'none';

    // Trigger openMenu action
    fetch(`https://${GetParentResourceName()}/openMenu`, {
        method: 'POST',
    });
});



document.getElementById('closeButton').addEventListener('click', () => {
    document.getElementById('bankMenu').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
});

const modal = document.getElementById('modal');
const modalTitle = document.getElementById('modalTitle');
const modalInput = document.getElementById('modalInput');
const modalTarget = document.getElementById('modalTarget');
const confirmButton = document.getElementById('confirmButton');
const cancelButton = document.getElementById('cancelButton');

let currentAction = null;

// Show modal
function openModal(action) {
    modal.style.display = 'flex';
    modalInput.value = '';
    modalTarget.value = '';
    modalTarget.style.display = action === 'transfer' ? 'block' : 'none';

    switch (action) {
        case 'deposit':
            modalTitle.textContent = 'Deposit Money';
            break;
        case 'withdraw':
            modalTitle.textContent = 'Withdraw Money';
            break;
        case 'transfer':
            modalTitle.textContent = 'Transfer Money';
            break;
    }
    currentAction = action;
}

// Close modal
function closeModal() {
    modal.style.display = 'none';
    currentAction = null;
}

// Handle confirm
confirmButton.addEventListener('click', () => {
    const amount = parseFloat(modalInput.value);
    const targetId = parseInt(modalTarget.value);

    if (!amount || amount <= 0 || (currentAction === 'transfer' && !targetId)) {
        alert('Please enter a valid amount or target ID.');
        return;
    }

    switch (currentAction) {
        case 'deposit':
            fetch(`https://${GetParentResourceName()}/deposit`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ amount })
            });
            break;
        case 'withdraw':
            fetch(`https://${GetParentResourceName()}/withdraw`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ amount })
            });
            break;
        case 'transfer':
            fetch(`https://${GetParentResourceName()}/transfer`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ amount, targetId })
            });
            break;
    }

    closeModal();
});

// Handle cancel
cancelButton.addEventListener('click', closeModal);

// Attach modal to buttons
document.getElementById('depositButton').addEventListener('click', () => openModal('deposit'));
document.getElementById('withdrawButton').addEventListener('click', () => openModal('withdraw'));
document.getElementById('transferButton').addEventListener('click', () => openModal('transfer'));
