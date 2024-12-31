import Application from 'test-app/app';
import QUnit from 'qunit';
import config from 'test-app/config/environment';
import { loadTests } from 'ember-qunit/test-loader';
import { setApplication } from '@ember/test-helpers';
import { setup } from 'qunit-dom';
import { start, setupEmberOnerrorValidation } from 'ember-qunit';

setupEmberOnerrorValidation();
loadTests();

setApplication(Application.create(config.APP));

setup(QUnit.assert);
start();
