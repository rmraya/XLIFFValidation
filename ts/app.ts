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

    constructor() {
        let path: string = location.pathname;
        let n: number = path.lastIndexOf('/');
        if (n !== -1) {
            path = path.substring(0, n);
        }
        this.mainURL = 'https://' + location.host + path;

        document.getElementById('xliffFile').addEventListener('input', () => {
            this.validateFile();
        });

        this.getVersion();
    }

    validateFile(): void {
        let formData: FormData = new FormData();
        let xliffFile: HTMLInputElement = document.getElementById('xliffFile') as HTMLInputElement;
        if (xliffFile.files) {
            let check: HTMLInputElement = document.getElementById('schematron') as HTMLInputElement;
            let useSchematron: string = check.checked ? "yes" : "no";
            formData.append('xliff', xliffFile.files[0]);
            fetch(this.mainURL + '/upload', {
                method: 'POST',
                body: formData,
                headers: [
                    ['session', this.session],
                    ['Accept', 'application/json'],
                    ['schematron', useSchematron]
                ]
            })
                .then((response: Response) => response.json())
                .then((json: any) => {
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
                })
                .catch((reason: any) => {
                    console.error('Error:', reason);
                });
        } else {
            window.alert('Select XLIFF file');
            return;
        }
    }

    getVersion(): void {
        fetch(this.mainURL + '/version', {
            method: 'GET',
            headers: [
                ['Accept', 'application/json']
            ]
        })
            .then((response: Response) => response.json())
            .then((json: any) => {
                if (json.status === 'OK') {
                    let versionSpan: HTMLSpanElement = document.getElementById('version');
                    if (versionSpan) {
                        versionSpan.innerHTML = json.version;
                    }
                    this.session = json.session;
                } else {
                    window.alert(json.reason);
                }
            })
            .catch((reason: any) => {
                console.error('Error:', reason);
            });
    }
}

new App();