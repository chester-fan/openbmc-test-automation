*** Settings ***
Documentation          This example demonstrates executing commands on a remote machine
...                    and getting their output and the return code.
...
...                    Notice how connections are handled as part of the suite setup and
...                    teardown. This saves some time when executing several test cases.

Resource               ../lib/rest_client.robot
Resource               ../lib/ipmi_client.robot
Resource               ../lib/openbmc_ffdc.robot
Resource               ../lib/state_manager.robot
Library                ../data/model.py
Resource               ../lib/boot_utils.robot
Resource               ../lib/utils.robot

Suite Setup            Setup The Suite
Test Setup             Open Connection And Log In
Test Teardown          Post Test Case Execution

*** Variables ***

${stack_mode}     skip
${model}=         ${OPENBMC_MODEL}

*** Test Cases ***

Verify IPMI BT Capabilities Command
    [Documentation]  Verify IPMI BT capability command response.
    [Tags]  Verify_IPMI_BT_Capabilities_Command
    [Setup]  REST Power On

    ${output}=  Run IPMI command  0x06 0x36
    Should Be True  "${output}" == " 01 3f 3f 0a 01"
    ...  msg=Incorrect Output

io_board Present
    [Tags]  io_board_Present
    ${uri}=  Get System component  io_board
    Verify The Attribute  ${uri}  Present  ${True}

io_board Fault
    [Tags]  io_board_Fault
    ${uri}=  Get System component  io_board
    Verify The Attribute  ${uri}  fault  ${False}

*** Keywords ***

Setup The Suite
    [Documentation]  Initial suite setup.

    # Boot Host.
    REST Power On

    Open Connection And Log In
    ${resp}=   Read Properties   ${OPENBMC_BASE_URI}enumerate   timeout=30
    Set Suite Variable      ${SYSTEM_INFO}          ${resp}
    log Dictionary          ${resp}

Get System component
    [Arguments]    ${type}
    ${list}=    Get Dictionary Keys    ${SYSTEM_INFO}
    ${resp}=    Get Matches    ${list}    regexp=^.*[0-9a-z_].${type}[0-9]*$
    ${url}=    Get From List    ${resp}    0
    [Return]    ${url}

Verify The Attribute
    [Arguments]  ${uri}  ${parm}  ${value}
    # Description of arguments:
    # ${uri}  URI path.
    # ${parm}  Attribute.
    # ${value}  Output to be compared.

    ${output}=  Read Attribute  ${uri}  ${parm}
    Should Be Equal  ${value}  ${output}

Post Test Case Execution
    [Documentation]  Do the post test teardown.
    ...  1. Capture FFDC on test failure.
    ...  2. Close all open SSH connections.

    FFDC On Test Case Fail
    Close All Connections
