*** Settings ***
Documentation  Set metadata for test suite.

Library          SSHLibrary
Resource         ../lib/connection_client.robot
Resource         ../lib/rest_client.robot

Suite Setup      System Driver Data

*** Variables ***

${DRIVER_CMD}    cat /etc/os-release | grep ^VERSION_ID=

*** Keyword ***

System Driver Data
    [Documentation]  System driver information.
    Run Keyword And Ignore Error  Get BMC Driver Details
    Run Keyword And Ignore Error  Get PNOR Driver Details

Get BMC Driver Details
    [Documentation]   Get BMC driver details and log.

    Open Connection And Log In
    ${output}  ${stderr}=  Execute Command  ${DRIVER_CMD}
    ...  return_stderr=True
    Should Be Empty  ${stderr}
    Log  ${output}
    [Return]  ${output}


Get PNOR Driver Details
    [Documentation]   Get PNOR driver details and log.
    ${resp}=
    ...  OpenBMC Get Request  ${INVENTORY_URI}system/bios
    Should Be Equal As Strings  ${resp.status_code}  ${HTTP_OK}
    ${jsondata}=  To Json  ${resp.content}
    Log  ${jsondata["data"]["Name"]}
    Log  ${jsondata["data"]["Version"]}
    Log  ${jsondata["data"]["Custom Field 1"]}
    Log  ${jsondata["data"]["Custom Field 2"]}
    Log  ${jsondata["data"]["Custom Field 3"]}
    Log  ${jsondata["data"]["Custom Field 4"]}
    Log  ${jsondata["data"]["Custom Field 5"]}
    Log  ${jsondata["data"]["Custom Field 6"]}
    Log  ${jsondata["data"]["Custom Field 7"]}
    Log  ${jsondata["data"]["Custom Field 8"]}
