const NO_RESULT_MESSAGE_BEGINNING = 'Request returned no results for the specified ';
const NO_RESULT_MESSAGE_END = ' please contact support';
const CONNECTION_ERROR_MESSAGE = 'Connection error – please contact STANLIB Salesforce Support';
const NOT_FOUND_STATUS_CODE = '404';
const INVALID_VALUE_STATUS_CODE = '400';

export { getErrorMessage };

const getErrorMessage = (parametersNotSet, error, strParamsDescription) => {
  console.log('getErrorMessage ', parametersNotSet);
  let message = error.body.message;
  let errorMessage;
  if (parametersNotSet) {
    errorMessage = message;
  } else if (message.includes(NOT_FOUND_STATUS_CODE) || message.includes(INVALID_VALUE_STATUS_CODE)) {
    errorMessage = NO_RESULT_MESSAGE_BEGINNING + strParamsDescription + NO_RESULT_MESSAGE_END;
  } else {
    errorMessage = CONNECTION_ERROR_MESSAGE;
  }

  console.error(error);
  return errorMessage;
};