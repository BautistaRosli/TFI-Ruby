// Modal personalizado de confirmación
class CustomModal {
    constructor() {
        this.createModal();
        this.currentForm = null;
    }

    createModal() {
        const modalHTML = `
            <div id="customModal" class="custom-modal-overlay">
                <div class="custom-modal">
                    <div class="custom-modal-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995A.905.905 0 0 1 8 5zm.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
                        </svg>
                    </div>
                    <h3 class="custom-modal-title">Confirmar Eliminación</h3>
                    <p class="custom-modal-message" id="modalMessage"></p>
                    <div class="custom-modal-footer">
                        <button type="button" class="custom-modal-btn custom-modal-btn-cancel" id="modalCancel">Cancelar</button>
                        <button type="button" class="custom-modal-btn custom-modal-btn-confirm" id="modalConfirm">Eliminar</button>
                    </div>
                </div>
            </div>
        `;

        document.body.insertAdjacentHTML('beforeend', modalHTML);

        this.modal = document.getElementById('customModal');
        this.messageEl = document.getElementById('modalMessage');
        this.cancelBtn = document.getElementById('modalCancel');
        this.confirmBtn = document.getElementById('modalConfirm');

        this.cancelBtn.addEventListener('click', () => this.close());
        this.confirmBtn.addEventListener('click', () => this.confirm());
        this.modal.addEventListener('click', (e) => {
            if (e.target === this.modal) this.close();
        });
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.modal.classList.contains('active')) this.close();
        });
    }

    show(message, form) {
        this.messageEl.textContent = message;
        this.currentForm = form;
        this.modal.classList.add('active');
    }

    close() {
        this.modal.classList.remove('active');
        this.currentForm = null;
    }

    confirm() {
        if (this.currentForm) {
            this.currentForm.onsubmit = null;
            this.currentForm.submit();
        }
        this.close();
    }
}

document.addEventListener('DOMContentLoaded', () => {
    const modal = new CustomModal();
    document.addEventListener('submit', (e) => {
        const form = e.target;
        if (form.hasAttribute('data-confirm')) {
            e.preventDefault();
            modal.show(form.getAttribute('data-confirm'), form);
        }
    });
});
