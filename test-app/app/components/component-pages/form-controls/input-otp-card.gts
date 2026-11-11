import { array, hash } from '@ember/helper';
import { InputOtp } from 'frontile';
import WorkbenchCard from 'test-app/components/workbench/card';
import WorkbenchSection from 'test-app/components/workbench/section';
import WorkbenchPanes from 'test-app/components/workbench/panes';
import WorkbenchSpecimen from 'test-app/components/workbench/specimen';
import WorkbenchStateMatrix from 'test-app/components/workbench/state-matrix';
import { INPUT_OTP_SIZES } from 'test-app/utils/workbench/options';
import { FORM_STATES_NO_FOCUS } from './states';

// Four md cells per column overflow the pane; the Sizes section shows md.
const ROWS = ['sm'] as const;

<template>
  <WorkbenchCard
    @id="input-otp"
    @title="InputOTP"
    @description="A one-time-code field: one real input over display cells. The active-cell ring follows a real focus event, so it cannot be frozen and the focus columns are omitted; click a field to see it."
    @sections={{array
      (hash id="states" label="States")
      (hash id="sizes" label="Sizes")
    }}
  >
    <WorkbenchSection @id="input-otp-states" @title="States">
      <WorkbenchPanes @stacked={{true}}>
        <WorkbenchStateMatrix
          @rows={{ROWS}}
          @states={{FORM_STATES_NO_FOCUS}}
          @rowLabel="Size"
          as |size state cell|
        >
          <InputOtp
            @size={{size}}
            @length={{4}}
            @value={{if cell.isFilled "1234"}}
            @isDisabled={{cell.isDisabled}}
            @isInvalid={{cell.isInvalid}}
            readonly={{cell.isReadonly}}
            aria-label="Code {{state}}"
          />
        </WorkbenchStateMatrix>
      </WorkbenchPanes>
    </WorkbenchSection>

    <WorkbenchSection @id="input-otp-sizes" @title="Sizes">
      <div class="flex flex-col gap-6">
        {{#each INPUT_OTP_SIZES as |size|}}
          <WorkbenchSpecimen @label={{size}}>
            <InputOtp
              @size={{size}}
              @label="Verification code"
              @groups={{array 3 3}}
              @value="123"
            />
          </WorkbenchSpecimen>
        {{/each}}
      </div>
    </WorkbenchSection>
  </WorkbenchCard>
</template>
