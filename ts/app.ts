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

    constructor() {
        let path: string = location.pathname;
        let n: number = path.lastIndexOf('/');
        if (n !== -1) {
            path = path.substring(0, n);
        }
        this.mainURL = 'https://' + location.host + path;

        this.getVersion();
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