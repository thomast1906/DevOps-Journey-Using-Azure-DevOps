# Configure Availability Tests Using Application Insights

# 🎯 Purpose
Set up recurring tests to monitor your application's availability and responsiveness using Application Insights.

You can set up recurring tests to monitor the availability and responsiveness of your application using Application Insights. These tests send web requests to your application at regular intervals from various locations around the world and alert you if your application is unresponsive or slow.

Availability tests can be configured for any HTTP or HTTPS endpoint accessible from the public internet. No modifications to the website being tested are necessary, and the site does not need to be owned by you. For example, you can test the availability of a REST API that your service depends on.

## Types of tests

There are four types of availability tests:

1. **URL Ping Test (Classic):** This simple test can be created through the portal to check if an endpoint is responding and measure the performance of the response. You can set custom success criteria and utilize advanced features such as parsing dependent requests and allowing retries.

2. **Standard Test (Preview):** Similar to the URL ping test, this single request test includes additional features such as SSL certificate validity checks, proactive lifetime checks, various HTTP request verbs (e.g., GET, HEAD, POST), custom headers, and custom data associated with your HTTP request.

3. **Multi-Step Web Test (Classic):** This test involves recording a sequence of web requests to simulate more complex scenarios. Multi-step web tests are created in Visual Studio Enterprise and uploaded to the portal for execution.

4. **Custom TrackAvailability Test:** For custom applications running availability tests, the TrackAvailability() method can be used to send test results to Application Insights.

### 🔍 Verification:
1. Confirm you understand the differences between each test type

### 🧠 Knowledge Check:
1. Which test type is best suited for complex scenarios?
2. What unique features does the Standard Test (Preview) offer?

#### 💡 Pro Tip: Choose the test type that best matches your application's complexity and your monitoring needs.


# 1. Configuring a clasic test and viewing results

To configure a classic availability test, follow these steps:

1. Navigate to **Availability** and select **Add Classic Test**
2. Enter the necessary details, including the URL of the endpoint you wish to test. The URL should be the ingress IP used to access the test application.

![](images/monitoring-and-alerting-7.PNG)

After configuring the test, you will be able to view detailed testing information over time.

![](images/monitoring-and-alerting-8.PNG)

## 🔍 Verification:
1. Successfully create a new classic test
2. Confirm the test appears in the Availability tests list
3. Check that test results are being recorded and displayed correctly

## 🧠 Knowledge Check:

1. What parameters can you configure for a classic test?
2. How does the test frequency affect your monitoring strategy?
3. What metrics are most important when reviewing availability test results?
4. How can you use these results to improve your application's reliability?

#### 💡 Pro Tip: Start with a higher test frequency during initial setup or after major changes, then adjust based on your application's stability.
