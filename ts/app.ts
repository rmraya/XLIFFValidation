/*******************************************************************************
 * Copyright (c) 2021 Maxprograms.
 *
 * This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 1.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/org/documents/epl-v10.html
 *
 * Contributors:
 *     Maxprograms - initial API and implementation
 *******************************************************************************/

class App {

    mainURL: string;
    session: string;
    dropArea: HTMLDivElement;
    fileInput: HTMLInputElement;

    constructor() {
        let path: string = location.pathname;
        let n: number = path.lastIndexOf('/');
        if (n !== -1) {
            path = path.substring(0, n);
        }
        this.mainURL = 'https://' + location.host + path;

        this.dropArea = document.getElementById('dropArea') as HTMLDivElement;
        this.dropArea.addEventListener('dragover', (ev: DragEvent) => { this.dragOverHandler(ev); });
        this.dropArea.addEventListener('dragleave', () => { this.dragExitHandler(); });
        this.dropArea.addEventListener('drop', (ev: DragEvent) => { this.dropHandler(ev); });

        this.fileInput = document.getElementById('xliffFile') as HTMLInputElement;
        this.fileInput.addEventListener('input', () => {
            this.validateFile();
        });

        this.getVersion();
    }

    validateFile(): void {
        let formData: FormData = new FormData();
        if (this.fileInput.files) {
            document.getElementById('result').innerText = 'Validating...';
            document.getElementById('schemaresult').innerText = '';
            let check: HTMLInputElement = document.getElementById('schematron') as HTMLInputElement;
            let useSchematron: string = check.checked ? "yes" : "no";
            formData.append('xliff', this.fileInput.files[0]);
            fetch(this.mainURL + '/upload', {
                method: 'POST',
                body: formData,
                headers: [
                    ['session', this.session],
                    ['Accept', 'application/json'],
                    ['schematron', useSchematron]
                ]
            }).then(async (response: Response) => {
                let json: any = await response.json();
                if (json.status === 'OK') {
                    document.getElementById('result').innerText = 'File "' + json.xliff + '" is valid XLIFF ' + json.version;
                } else {
                    document.getElementById('result').innerText = 'File "' + json.xliff + '" is not valid XLIFF. \n\nReason: ' + json.reason;
                }
                if (json.schemaValidation) {
                    let result: string = 'Schematron result: ' + json.schemaValidation;
                    if (json.schemaReason) {
                        result = 'Schematron result: ' + json.schemaReason;
                    }
                    document.getElementById('schemaresult').innerText = result;
                }
            }).catch((reason: Error) => {
                console.error('Error:', reason.message);
                window.alert(reason);
            });
        } else {
            window.alert('Select XLIFF file');
            return;
        }
    }

    dragOverHandler(event: DragEvent): void {
        event.preventDefault();
        this.dropArea.classList.add('dragOver');
    }

    dragExitHandler(): void {
        this.dropArea.classList.remove('dragOver');
    }

    dropHandler(event: DragEvent): void {
        if (event.dataTransfer.files) {
            event.preventDefault();
            this.fileInput.files = event.dataTransfer.files;
            if (this.fileInput.files) {
                this.validateFile();
            }
            this.dropArea.classList.remove('dragOver');
        }
    }

    getVersion(): void {
        fetch(this.mainURL + '/version', {
            method: 'GET',
            headers: [
                ['Accept', 'application/json']
            ]
        }).then(async (response: Response) => {
            let json: any = await response.json();
            if (json.status === 'OK') {
                let versionSpan: HTMLSpanElement = document.getElementById('version');
                if (versionSpan) {
                    versionSpan.innerHTML = json.version;
                }
                this.session = json.session;
            } else {
                window.alert(json.reason);
            }
        }).catch((reason: Error) => {
            console.error('Error:', reason.message);
        });
    }
}

new App();