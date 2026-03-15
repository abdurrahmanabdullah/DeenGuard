// src/common/filters/http-exception.filter.ts
import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();

    // Get the detailed error message
    let message = 'An error occurred';

    // Best practice: Detect the type of error and provide specific guidance.
    if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
      const errorObj = exceptionResponse as Record<string, unknown>;
      const originalMessage = errorObj.message;

      if (typeof originalMessage === 'string') {
        message = originalMessage;

        // Custom handling for JSON syntax errors (common during development)
        if (message.includes('Expected double-quoted property name in JSON')) {
          message = 'Invalid JSON format: Please check for trailing commas (e.g., {"key": "value",}) or typos in your request body.';
        } else if (message.includes('Unexpected token')) {
          message = `Invalid JSON: ${message}. Check your double quotes and brackets.`;
        }
      } else if (Array.isArray(originalMessage)) {
        // Validation errors usually come as an array
        message = (originalMessage as string[]).join(', ');
      }
    } else if (typeof exceptionResponse === 'string') {
      message = exceptionResponse;
    }

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      message: message,
    });
  }
}
