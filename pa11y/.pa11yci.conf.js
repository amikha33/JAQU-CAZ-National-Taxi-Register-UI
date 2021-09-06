var config = {
    defaults: {
        standard: 'WCAG2AA',
        concurrency: 1,
        // ignore issue with role=presentation on start button
        ignore: ["WCAG2AA.Principle1.Guideline1_3.1_3_1.F92,ARIA4"],
        // The time in milliseconds that a test should be allowed to run before calling back with a timeout error.
        timeout: 30000, // Maximum 30000ms(30 seconds)
        // The time in milliseconds to wait before running HTML CodeSniffer on the page.
        wait: 2500,
        chromeLaunchConfig: {
            args: [
                "--no-sandbox"
            ]
        }
    },
    urls: [
        {
            "url": "${BASE_URL}?home",
            "actions": [
                "wait for element #ccc-dismiss-button to be visible",
                "click element #ccc-dismiss-button",
                ]
        },
        {
            "url": "${BASE_URL}?upload",
            "actions": [
                "wait for element #user_username to be visible",
                "set field #user_username to tester@informed.com",
                "set field #user_password to Tester123...",
                "wait for element #sign_in_button to be visible",
                "click element #sign_in_button",
                "wait for element #file-upload-1 to be visible",
            ]
        },
        "${BASE_URL}/vehicles/search",
        {
            "url": "${BASE_URL}/vehicles/search?search-results",
            "actions": [
                "wait for element #search_button to be visible",
                "set field #vrn to IS19PCA",
                "click element #historical_off",
                "click element #search_button",
                "wait for element #new_search_button to be visible",
            ]
        },
        {
            "url": "${BASE_URL}/vehicles/search?search-results-historical",
            "actions": [
                "wait for element #search_button to be visible",
                "set field #vrn to IS19PCA",
                "click element #historical_on",
                "wait for element #search_start_date_day to be visible",
                "set field #search_start_date_day to 01",
                "set field #search_start_date_month to 01",
                "set field #search_start_date_year to 2021",
                "set field #search_end_date_day to 01",
                "set field #search_end_date_month to 02",
                "set field #search_end_date_year to 2021",
                "click element #search_button",
                "wait for element #search_another_vehicle to be visible",
            ]
        },

    ]
};

/**
 * Simple method to replace nested URLs in a pa11y configuration definition
 */
function replacePa11yBaseUrls(urls, defaults) {
    console.error('BASE_URL:', process.env.BASE_URL);
    //Iterate existing urls object from configuration
    for (var idx = 0; idx < urls.length; idx++) {
        if (typeof urls[idx] === 'object') {
            // If configuration object in URLs is a further nested object, replace inner url field value
            var nestedObject = urls[idx]
            nestedObject['url'] = nestedObject['url'].replace('${BASE_URL}', process.env.BASE_URL)
            urls[idx] = nestedObject;
        } else {
            // Otherwise replace simple string (see pa11y configuration guidance)
            urls[idx] = urls[idx].replace('${BASE_URL}', process.env.BASE_URL);
        }
    }

    result = {
        defaults: defaults,
        urls: urls
    }

    console.log('\n')
    console.log('Generated pa11y configuration:\n')
    console.log(result)

    return result
}

module.exports = replacePa11yBaseUrls(config.urls, config.defaults);
