/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-return */
// src/utils/string-utils.service.ts

import { Injectable } from '@nestjs/common';
import { camelCase, kebabCase, snakeCase, startCase } from 'lodash';
import * as pluralize from 'pluralize';

@Injectable()
export class StringUtilsService {
  /**
   * Check if a string is in singular form
   * Example: "apple" -> true, "apples" -> false
   * @param str The input string
   * @returns boolean indicating if string is singular
   */
  isSingular(str: string): boolean {
    return pluralize.isSingular(str);
  }

  /**
   * Check if a string is in plural form
   * Example: "apples" -> true, "apple" -> false
   * @param str The input string
   * @returns boolean indicating if string is plural
   */
  isPlural(str: string): boolean {
    return pluralize.isPlural(str);
  }

  /**
   * Check if a string is in camelCase
   * Example: "helloWorld" -> true, "HelloWorld" -> false
   * @param str The input string
   * @returns boolean indicating if string is camelCase
   */
  isCamelCase(str: string): boolean {
    return str === this.toCamelCase(str);
  }

  toTitleCase(str: string): string {
    if (str.endsWith('_id')) {
      str = str.slice(0, -3); // Remove _id
    }
    return startCase(camelCase(str));
  }

  /**
   * Convert a string to its singular form
   * Example: "apples" -> "apple"
   * @param str The input string
   * @returns The singularized string
   */
  singular(str: string): string {
    // Split by common separators while preserving them
    const parts = str.split(/(_|-)/);

    // Singularize each word part (skipping separators)
    const singularized = parts.map((part, index) => {
      // If it's a separator, keep it as is
      if (part === '_' || part === '-') return part;
      // Otherwise singularize the word
      return pluralize.singular(part);
    });

    // Join back together
    return singularized.join('');
  }

  /**
   * Convert a string to its plural form
   * Example: "apple" -> "apples"
   * @param str The input string
   * @returns The pluralized string
   */
  plural(str: string): string {
    return pluralize.plural(str);
  }

  /**
   * Convert a string to camelCase
   * Example: "hello world" -> "helloWorld"
   * @param str The input string
   * @returns The camelCase string
   */
  toCamelCase(str: string): string {
    return camelCase(str);
  }

  /**
   * Convert a string to PascalCase
   * Example: "hello world" -> "HelloWorld"
   * @param str The input string
   * @returns The PascalCase string
   */
  toPascalCase(str: string): string {
    return startCase(camelCase(str)).replace(/ /g, '');
  }

  /**
   * Convert a string to kebab-case (param-case)
   * Example: "HelloWorld" -> "hello-world"
   * @param str The input string
   * @returns The kebab-case string
   */
  toKebabCase(str: string): string {
    return kebabCase(str);
  }

  /**
   * Convert a string to snake_case
   * Example: "HelloWorld" -> "hello_world"
   * @param str The input string
   * @returns The snake_case string
   */
  toSnakeCase(str: string): string {
    return snakeCase(str);
  }

  randomString(length: number): string {
    const characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += characters.charAt(
        Math.floor(Math.random() * characters.length),
      );
    }
    return result;
  }

  /**
   * Creates a numeric hash from a string
   * @param str The string to hash
   * @returns A numeric hash value
   */
  hashString(str: string): number {
    let hash = 0;
    if (str.length === 0) return hash;

    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      hash = hash & hash; // Convert to 32bit integer
    }

    // Make sure the result is positive
    return Math.abs(hash);
  }
}
